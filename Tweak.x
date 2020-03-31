#import "NSTask.h"

NSDictionary *prefs;

%hook SpringBoard
-(void)applicationDidFinishLaunching:(bool)arg1{
	%orig();
	for(NSString *daemon in [prefs allKeys]){
		if([[prefs objectForKey:daemon] boolValue] == FALSE){
			NSTask *task = [NSTask new];
			[task setLaunchPath:@"/usr/libexec/launchctl_wrapper"];
			[task setArguments:@[@"unload", daemon]];
			[task launch];
		}
	}
}
%end

%ctor{
	prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.level3tjg.daemondisabler.plist"];
}