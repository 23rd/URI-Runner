//
//  AppDelegate.m
//  URIRunner
//
//  Created by HatanoKenta on 2019/02/19.
//  Copyright © 2019年 kenta. All rights reserved.
//

#import "AppDelegate.h"

#define AUTOMATOR_URL_PREFIX @"amrunner://"
#define APPLESCRIPT_URL_PREFIX @"quicktimerunner://"

#define auto __auto_type

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	[[NSAppleEventManager sharedAppleEventManager]
		setEventHandler:self
		andSelector:@selector(handleURLEvent:withReplyEvent:)
		forEventClass:kInternetEventClass
		andEventID:kAEGetURL];
}


- (void) applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (void) handleURLEvent:(NSAppleEventDescriptor*)event
		withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
	const auto url = [event
		paramDescriptorForKeyword:keyDirectObject].stringValue;

	if ([url hasPrefix:AUTOMATOR_URL_PREFIX]) {
		// TODO: execute Automator workflow
	} else if ([url hasPrefix:APPLESCRIPT_URL_PREFIX]) {
		auto source = [url
			stringByReplacingCharactersInRange:NSMakeRange(
				0,
				APPLESCRIPT_URL_PREFIX.length)
			withString:@""];
		source = [source stringByRemovingPercentEncoding];
		source = [source
			stringByReplacingOccurrencesOfString:@"https//"
			withString:@""];
		source = [source
			stringByReplacingOccurrencesOfString:@"http//"
			withString:@""];

		const auto task = [NSTask new];
		[task setLaunchPath:@"/bin/zsh"];
		[task setArguments:@[
			@"-c",
			[NSString stringWithFormat:@"source ~/.zshrc && qty %@", source]
		]];
		[task launch];

		[[NSApplication sharedApplication] terminate:self];
	}
}

@end
