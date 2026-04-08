package de.timthetimber.iconswitcher;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.ComponentName;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class IconSwitcherPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private PackageManager packageManager;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        this.context = flutterPluginBinding.getApplicationContext();
        this.channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "icon_switcher");
        this.channel.setMethodCallHandler(this);
        this.packageManager = context.getPackageManager();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "changeIcon": {
                String iconName = call.argument("iconName");
                String iconActivityAlias = call.argument("iconActivityAlias");
                if (iconName == null || iconActivityAlias == null) {
                    result.error("INVALID_ARGUMENTS", "iconName and iconActivityAlias are required on Android.", null);
                    return;
                }

                ComponentName mainActivity = findMainActivity();
                if (mainActivity == null) {
                    result.error("NO_DEFAULT_COMPONENT", "Could not detect the default launcher activity. Ensure your AndroidManifest.xml is configured correctly.", null);
                    return;
                }

                try {
                    if (iconName.equals("default")) {
                        // Switching back to default: disable all aliases, enable main activity
                        disableAllAliases();
                        enableComponent(mainActivity);
                    } else {
                        // Switching to an alias: disable everything (main + aliases), enable only the target
                        ComponentName newIconComponent = new ComponentName(context, iconActivityAlias);
                        disableAllLauncherComponents();
                        enableComponent(newIconComponent);
                    }
                    result.success(true);
                } catch (Exception e) {
                    result.error("CHANGE_ICON_FAILED", e.getMessage(), null);
                }
                break;
            }
            case "resetIcon": {
                ComponentName mainActivity = findMainActivity();
                if (mainActivity == null) {
                    result.error("NO_DEFAULT_COMPONENT", "Could not detect the default launcher activity.", null);
                    return;
                }
                try {
                    disableAllAliases();
                    enableComponent(mainActivity);
                    result.success(true);
                } catch (Exception e) {
                    result.error("RESET_ICON_FAILED", e.getMessage(), null);
                }
                break;
            }
            case "getCurrentIcon": {
                String currentIcon = getCurrentEnabledAlias();
                result.success(currentIcon);
                break;
            }
            case "isSupported": {
                result.success(true);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * Finds the real main activity (not an alias) by looking for the component
     * without a targetActivity. Falls back to package + ".MainActivity".
     */
    private ComponentName findMainActivity() {
        List<ActivityInfo> activities = getAllActivities();
        if (activities != null) {
            for (ActivityInfo info : activities) {
                if (info.targetActivity == null) {
                    return new ComponentName(context, info.name);
                }
            }
        }
        return new ComponentName(context, context.getPackageName() + ".MainActivity");
    }

    /**
     * Disables all launcher components — main activity AND all aliases.
     * Used when switching to an alias so only the target alias remains visible.
     */
    private void disableAllLauncherComponents() {
        List<ActivityInfo> activities = getAllActivities();
        if (activities == null) return;

        for (ActivityInfo info : activities) {
            ComponentName componentName = new ComponentName(context, info.name);
            packageManager.setComponentEnabledSetting(
                    componentName,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
            );
        }
    }

    /**
     * Disables only activity-aliases (components with targetActivity != null).
     * Used when resetting to the default icon.
     */
    private void disableAllAliases() {
        List<ActivityInfo> activities = getAllActivities();
        if (activities == null) return;

        for (ActivityInfo info : activities) {
            if (info.targetActivity != null) {
                ComponentName componentName = new ComponentName(context, info.name);
                packageManager.setComponentEnabledSetting(
                        componentName,
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                );
            }
        }
    }

    private void enableComponent(ComponentName componentName) {
        packageManager.setComponentEnabledSetting(
                componentName,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
        );
    }

    private String getCurrentEnabledAlias() {
        List<ActivityInfo> activities = getAllActivities();
        if (activities == null) return null;

        for (ActivityInfo info : activities) {
            if (info.targetActivity != null) {
                ComponentName componentName = new ComponentName(context, info.name);
                int state = packageManager.getComponentEnabledSetting(componentName);
                if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                    // Return just the simple class name (e.g., "First" from ".First" or "com.example.First")
                    String name = info.name;
                    int lastDot = name.lastIndexOf('.');
                    return lastDot >= 0 ? name.substring(lastDot + 1) : name;
                }
            }
        }
        return null; // Default icon is active
    }

    private List<ActivityInfo> getAllActivities() {
        try {
            PackageInfo pi = packageManager.getPackageInfo(
                    context.getPackageName(),
                    PackageManager.GET_ACTIVITIES | PackageManager.GET_DISABLED_COMPONENTS
            );
            if (pi.activities != null) {
                return new ArrayList<>(Arrays.asList(pi.activities));
            }
        } catch (PackageManager.NameNotFoundException e) {
            // Ignored
        }
        return null;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }
}
