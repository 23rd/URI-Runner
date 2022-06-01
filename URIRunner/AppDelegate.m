//
//  AppDelegate.m
//  URIRunner
//
//  Created by HatanoKenta on 2019/02/19.
//  Copyright © 2019年 kenta. All rights reserved.
//

#import "AppDelegate.h"

#define AUTOMATOR_URL_PREFIX @"amrunner://"
#define APPLESCRIPT_URL_PREFIX @"asrunner://"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *statusTextField;
@property (weak) IBOutlet NSProgressIndicator *statusProgressIndicator;

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
	NSString *url = [event
		paramDescriptorForKeyword:keyDirectObject].stringValue;

	if ([url hasPrefix:AUTOMATOR_URL_PREFIX]) {
		// TODO: execute Automator workflow
	} else if ([url hasPrefix:APPLESCRIPT_URL_PREFIX]) {
		[self.statusProgressIndicator setIndeterminate:YES];
		[self.statusProgressIndicator startAnimation:self];
		[self.statusTextField
			setStringValue:NSLocalizedString(@"Running AppleScript", nil)];

		NSString *source = [
				[url
					stringByReplacingCharactersInRange:NSMakeRange(
						0,
						APPLESCRIPT_URL_PREFIX.length)
					withString:@""]
			stringByRemovingPercentEncoding];
		NSAppleScript *appleScript = [[NSAppleScript alloc]
			initWithSource:source];

		NSDictionary *error;
		[appleScript executeAndReturnError:&error];
		// TODO: error handling

		[self.statusProgressIndicator setIndeterminate:NO];
		[self.statusProgressIndicator stopAnimation:self];
		[self.statusTextField setStringValue:NSLocalizedString(@"Idle", nil)];
	}
}

@end
