#include "include/basic_icon_switcher/basic_icon_switcher_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>

struct _IconSwitcherPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
};

G_DEFINE_TYPE(IconSwitcherPlugin, basic_icon_switcher_plugin, g_object_get_type())

static GdkPixbuf* create_pixbuf_from_data(const uint8_t* data, size_t length) {
  GInputStream* stream = g_memory_input_stream_new_from_data(
      g_memdup2(data, length), length, g_free);
  GError* error = nullptr;
  GdkPixbuf* pixbuf = gdk_pixbuf_new_from_stream(stream, nullptr, &error);
  g_object_unref(stream);
  if (error) {
    g_error_free(error);
    return nullptr;
  }
  return pixbuf;
}

static GtkWindow* get_window(IconSwitcherPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (!view) return nullptr;
  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

static void handle_method_call(IconSwitcherPlugin* self,
                               FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "changeIcon") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "INVALID_ARGUMENTS", "Arguments must be a map.", nullptr));
      fl_method_call_respond(method_call, response, nullptr);
      return;
    }

    FlValue* icon_data_value = fl_value_lookup_string(args, "iconData");
    if (!icon_data_value ||
        fl_value_get_type(icon_data_value) != FL_VALUE_TYPE_UINT8_LIST) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "INVALID_ARGUMENTS", "iconData (Uint8List) is required on Linux.",
          nullptr));
      fl_method_call_respond(method_call, response, nullptr);
      return;
    }

    const uint8_t* data = fl_value_get_uint8_list(icon_data_value);
    size_t length = fl_value_get_length(icon_data_value);

    GdkPixbuf* pixbuf = create_pixbuf_from_data(data, length);
    if (!pixbuf) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "INVALID_IMAGE", "Could not create image from the provided data.",
          nullptr));
      fl_method_call_respond(method_call, response, nullptr);
      return;
    }

    GtkWindow* window = get_window(self);
    if (window) {
      gtk_window_set_icon(window, pixbuf);
      g_object_unref(pixbuf);
      g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    } else {
      g_object_unref(pixbuf);
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "NO_WINDOW", "Could not find the application window.", nullptr));
    }
  } else if (strcmp(method, "resetIcon") == 0) {
    GtkWindow* window = get_window(self);
    if (window) {
      gtk_window_set_icon(window, nullptr);
      g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "NO_WINDOW", "Could not find the application window.", nullptr));
    }
  } else if (strcmp(method, "getCurrentIcon") == 0) {
    g_autoptr(FlValue) result = fl_value_new_null();
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "isSupported") == 0) {
    g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  IconSwitcherPlugin* plugin = BASIC_ICON_SWITCHER_PLUGIN(user_data);
  handle_method_call(plugin, method_call);
}

static void basic_icon_switcher_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(basic_icon_switcher_plugin_parent_class)->dispose(object);
}

static void basic_icon_switcher_plugin_class_init(IconSwitcherPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = basic_icon_switcher_plugin_dispose;
}

static void basic_icon_switcher_plugin_init(IconSwitcherPlugin* self) {}

void basic_icon_switcher_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  IconSwitcherPlugin* plugin = BASIC_ICON_SWITCHER_PLUGIN(
      g_object_new(basic_icon_switcher_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), "basic_icon_switcher",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
