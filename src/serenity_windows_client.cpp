#define WIN32_LEAN_AND_MEAN
#define WINVER 0x0A00
#define _WIN32_WINNT 0x0A00


#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdlib.h>
#include <stdio.h>

#pragma comment (lib, "Ws2_32.lib")
#pragma comment (lib, "Mswsock.lib")
#pragma comment (lib, "AdvApi32.lib")

#define PORT "8080"
#define MAX_THREADS 3
/*
    Function Prototypes
*/
SOCKET getSOCKET(char const* argv[]);

DWORD WINAPI updateChat(LPVOID param);


int __cdecl main(int argc, char const* argv[]){


        //The winsocks initialization code...
/*----------------------------------------------------------------------------*/
    WSADATA wsaData;


    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0)
        {
                 //if WSAStartup returns anything but 0, there was an error...
                 fprintf(stderr, "WSAStartup failed.\n");
                 system("PAUSE");
                 WSACleanup();
                 exit(1);
        }
/*----------------------------------------------------------------------------*/

    
    /*
        Variables
    */
    int iResult = 0;
    HANDLE hThread = nullptr;
    LPDWORD threadID = 0;
    SOCKET ConnectSocket = 0;
    const int bufferLength = 1024;
    char message[bufferLength];
    


    /*
        Initialize Socket
    */
    ConnectSocket = getSOCKET(argv);

    if(ConnectSocket == INVALID_SOCKET){
        ExitProcess(1);
    }

    /*
        Spawning chat update thread
    */
    hThread = CreateThread(
        NULL,
        0,
        updateChat,
        (LPVOID) ConnectSocket,
        0,
        threadID

    );

    /*
        Testing if thread was created
    */
    if(hThread == NULL){
        ExitProcess(3);
    }

    /*
        Main While loop for connection
    */
    while(ConnectSocket != INVALID_SOCKET){

        //get a message from the terminal
        fgets(message,bufferLength,stdin);

        //send message
        iResult = send(ConnectSocket, message, bufferLength, 0);
    }

    return 0;
}

/*
    Author: Parker DelBene
    Name: getSOCKET
    Description: Function for returning the needed socket information for Windows.


*/
SOCKET getSOCKET(char const* argv[]){

    // Defining structure info for Windows Socket
    struct addrinfo* result = NULL, *ptr = NULL, hints;
    int iResult;

    // Creating a socket with default type as Invalid
    SOCKET ConnectSocket = INVALID_SOCKET;

    // Defining parameters for getaddringo socket call
    ZeroMemory(&hints, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;

    // getting the result of getaddrinfo
    iResult = getaddrinfo(argv[1],PORT,&hints,&result);

    if(iResult != 0){
        perror("getaddrinfo failed");
        WSACleanup();
        ExitProcess(1);
    }

    //getting the results from getaddrinfo
    ptr = result;

    // creating the socket
    ConnectSocket = socket(ptr->ai_family, ptr->ai_socktype, ptr->ai_protocol);


    // checking if the socket is valid
    if(ConnectSocket == INVALID_SOCKET){
        perror("failed to create socket");
        freeaddrinfo(result);
        WSACleanup();
        ExitProcess(1);
    }

    // connecting to server
    iResult = connect(ConnectSocket, ptr->ai_addr, (int) ptr->ai_addrlen);

    //verifying connection
    if(iResult == SOCKET_ERROR){
        closesocket(ConnectSocket);
        ConnectSocket = INVALID_SOCKET;
    }

    freeaddrinfo(result);

    // return with error code if connection failed
    if(ConnectSocket == INVALID_SOCKET){
        perror("bad connection");
        WSACleanup();
        ExitProcess(1);

    }

    return ConnectSocket;
}

/*
    Author: Parker DelBene
    Name: updateChat
    Description: function called by a thread to automatically receive from the ConnectSocket and update chatlog
*/
DWORD WINAPI updateChat(LPVOID param){

    SOCKET ConnectSocket = (SOCKET) param;
    int result = 0;
    const int bufferLength = 1024;
    char message[bufferLength];

    /*
        Loop until invalid socket
    */
    while(ConnectSocket != INVALID_SOCKET){
        result = recv(ConnectSocket, message, bufferLength,0);

        if(result > 0){
            printf("%s\n", message);
        }
    }

    return 0;
}