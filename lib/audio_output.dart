import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:win32/win32.dart';

const _pacatBin = 'pacat';
const REFTIMES_PER_SEC = 10000000;
const REFTIMES_PER_MILLISEC =  10000;

class AudioOutput {
  /*
    Constructor for the AudioOutput

    Generates a queue of AudioPlayers that get cycled
    through the play sounds coming in from the network
    stream.
  */
  AudioOutput(){
    if(Platform.isLinux){
      initLinuxAudioProcess();
    }
    else if(Platform.isWindows){
      initWindowsAudioProcess();
    }
     
  
  }
  Process? _linuxAudioOutputProcess;
  /*
    Variables needed to fill Windows Sound Buffer
  */
  Pointer<Pointer<BYTE>> windowsSoundData = nullptr;
  Pointer<UINT32> windowsBufferFrameSize = nullptr;
  late Pointer<UINT32> windowsNumFrameAvailable;
  late Pointer<UINT32> windowsNumFramePadding;
  late List<Uint8> dataBuffer;
  late IAudioRenderClient renderClient;
  late IAudioClient audioClient;

  bool initialized = false;


  void addStream(Stream<dynamic> audioStream){
    audioStream.listen((data){
      if(Platform.isLinux){
        _linuxAudioOutputProcess!.stdin.add(data);
      }
      else if(Platform.isWindows){
        Uint8List temp  = data as Uint8List;
        
        audioClient.getCurrentPadding(windowsNumFramePadding);

        windowsNumFrameAvailable[0] = windowsBufferFrameSize[0] - windowsNumFramePadding[0];
        
        renderClient.getBuffer(windowsNumFrameAvailable[0], windowsSoundData);

        for(int i = 0; i < temp.lengthInBytes; i++){
          windowsSoundData[i][0] = temp[i];
        }

        renderClient.releaseBuffer(windowsNumFrameAvailable[0], 0);
      }
      
    });
  }

  Future<void> initLinuxAudioProcess()async{
    _linuxAudioOutputProcess = await Process.start(_pacatBin, []);
    if(_linuxAudioOutputProcess != null){
      initialized = true;
    }
  }

  Future<void> initWindowsAudioProcess()async{
    
    int hr;
    IMMDeviceEnumerator pEnumerator;
    Pointer<Pointer<COMObject>> pDevice = nullptr;
    IMMDevice audioDevice;
    Pointer<Pointer<COMObject>>? pAudioClient = nullptr;
    
    Pointer<Pointer<COMObject>> pRenderClient = nullptr;
    
    Pointer<Pointer<WAVEFORMATEX>> pwfx = nullptr;
    

    pEnumerator = IMMDeviceEnumerator(COMObject.createFromID(CLSID_MMDeviceEnumerator, IID_IMMDeviceEnumerator));

    hr = pEnumerator.getDefaultAudioEndpoint(eRender, eConsole, pDevice);
    
    if(FAILED(hr)){
      initialized = false;
      return;
    }
   
    audioDevice = IMMDevice(pDevice[0]);

    hr = audioDevice.activate(GUIDFromString(IID_IAudioClient), CLSCTX_ALL, nullptr, pAudioClient);

    if(FAILED(hr)){
      initialized = false;
      return;
    }

    audioClient = IAudioClient(pAudioClient[0]);

    hr = audioClient.getMixFormat(pwfx);

    if(FAILED(hr)){
      initialized = false;
      return;
    }

    hr = audioClient.initialize(AUDCLNT_SHAREMODE_SHARED, 0, REFTIMES_PER_SEC, 0, pwfx[0], nullptr);

    if(FAILED(hr)){
      initialized = false;
      return;
    }

    hr = audioClient.getBufferSize(windowsBufferFrameSize);

    if(FAILED(hr)){
      initialized = false;
      return;
    }

    hr = audioClient.getService(GUIDFromString(IID_IAudioRenderClient), pRenderClient);

    if(FAILED(hr)){
      initialized = false;
      return;
    }

    renderClient = IAudioRenderClient(pRenderClient[0]);

    hr = renderClient.getBuffer(windowsBufferFrameSize[0].toInt(), windowsSoundData);

    if(FAILED(hr)){
      initialized = false;
      return;
    }

    audioClient.start();
  }

 
}
