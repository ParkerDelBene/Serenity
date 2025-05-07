#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <pipewire/pipewire.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  flMethodChannel* pipewire_init_channel;
  flMethodChannel* pipewire_list_devices_channel;
  flMethodChannel* pipewire_get_device_stream_channel;
};

/*
  Types for listening to microphone and retrieving buffer
*/
struct data {
  struct pw_main_loop* loop;
  struct pw_stream* stream;
  double accumulator;
};

static const struct pw_stream_events stream_events = {
  PW_VERSION_STREAM_EVENTS,
  .process = on_process,
};

struct data* data;

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

/*
  Implement the pipewire method handlers
*/
static FlMethodResponse* pipewire_init(){
  data = {0,}
  uint8_t buffer[1024];

  pw_init(NULL, NULL);

  data->loop = pw_main_loop_new(NULL);
  data->stream = pw_stream_new(pw_main_loop_get_loop(data->loop), "capture-stream", 
    pw_properties_new(
      PW_KEY_MEDIA_TYPE, "Audio",
      PW_KEY_MEDIA_CATEGORY, "Capture",
      PW_KEY_MEDIA_ROLE, "Audio/Source",
      NULL
    ),
    );

  pw_stream_add_listener(stream, NULL, [](void *data, pw_stream_state_t old, pw_stream_state_t state, const char *error) {
        if (state == PW_STREAM_STATE_ERROR) {
            return FL_METHOD_RESPONSE(fl_method_error_response_new(
              "ERROR", "Error with Initializing Stream", nullptr));
        }
    }, NULL);

  pw_stream_connect(stream, PW_DIRECTION_INPUT, PW_ID_ANY, PW_STREAM_FLAG_AUTOCONNECT, NULL);

  pw_main_loop_run(main_loop);

  return FL_METHOD_RESPONSE(fl_method_success_response_new(0));
}


// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "serenity");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "serenity");
  }

  gtk_window_set_default_size(window, 1280, 720);
   gtk_window_maximize(window);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  /*
    Initializing the pipewire channels
  */
  self->pipewire_init_channel = fl_method_channel_new(
    fl_engine_get_binary_messenger(fl_view_get_engine(view)),
    "serenity.microphone/pipewire_init", FL_METHOD_CODEC(codec));
  self->pipewire_list_devices_channel = fl_method_channel_new(
    fl_engine_get_binary_messenger(fl_view_get_engine(view)),
    "serenity.microphone/pipewire_list_devices", FL_METHOD_CODEC(codec));
  self->pipewire_get_device_stream_channel = fl_event_channel_new(
    fl_engine_get_binary_messenger(fl_view_get_engine(view)),
    "serenity.microphone/pipewire_get_device_stream", FL_METHOD_CODEC(codec));


  /*
    Initializing the fl_remethods for using pipewire on linux
  */
  fl_method_channel_set_method_call_handler(self->pipewire_init_channel,pipewire_init_method_call_handler, self, nullptr);
  fl_method_channel_set_method_call_handler(self->pipewire_list_devices_channel,pipewire_list_devices_method_call_handler, self, nullptr);
  fl_event_channel_set_event_call_handler(self->pipewire_get_device_stream_channel,pipewire_get_device_stream_method_call_handler, self, nullptr);


  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&self->pipewire_init_channel);
  g_clear_object($self->pipewire_list_devices_channel);
  g_clear_object($self->pipewire_get_device_stream_channel);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
