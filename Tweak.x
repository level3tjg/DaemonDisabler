#include <spawn.h>
#include <signal.h>

NSDictionary *prefs;

%hook SpringBoard
-(void)applicationDidFinishLaunching:(bool)arg1{
	%orig();
	for(NSString *daemon in [prefs allKeys]){
		if([[prefs objectForKey:daemon] boolValue] == FALSE){
			pid_t pid;
			int status;
			const char *argv[] = {"launchctl_wrapper", "unload", [daemon UTF8String], NULL};
			posix_spawn(&pid, "/usr/libexec/launchctl_wrapper", NULL, NULL, (char* const*)argv, NULL);
			waitpid(pid, &status, WEXITED);
		}
	}
}
%end

%ctor{
	prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.level3tjg.daemondisabler.plist"];
}