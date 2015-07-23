#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <substrate.h>

#define ENABLEDNC ([preferences objectForKey: @"ENABLE_NC"] ? [[preferences objectForKey: @"ENABLE_NC"] boolValue] : YES)
#define ENABLEDCC ([preferences objectForKey: @"ENABLE_CC"] ? [[preferences objectForKey: @"ENABLE_CC"] boolValue] : YES)
#define ENABLEDBANNERS ([preferences objectForKey: @"ENABLE_BANNERS"] ? [[preferences objectForKey: @"ENABLE_BANNERS"] boolValue] : YES)
#define ENABLEDDOCK ([preferences objectForKey: @"ENABLE_DOCK"] ? [[preferences objectForKey: @"ENABLE_DOCK"] boolValue] : NO)
#define ENABLE_APP_CARDS ([preferences objectForKey: @"ENABLE_APP_CARDS"] ? [[preferences objectForKey: @"ENABLE_APP_CARDS"] boolValue] : YES)
#define SHOWSTATUS ([preferences objectForKey: @"SHOWSTATUS"] ? [[preferences objectForKey: @"SHOWSTATUS"] boolValue] : NO)
#define ENABLE_UI_ALERT_MENU ([preferences objectForKey: @"ENABLE_UI_ALERT_MENU"] ? [[preferences objectForKey: @"ENABLE_UI_ALERT_MENU"] boolValue] : YES)

#define WIDTH_FOR_ORIENTATION(orientation) (UIInterfaceOrientationIsLandscape(orientation) \
	? [UIScreen mainScreen].bounds.size.height \
	: [UIScreen mainScreen].bounds.size.width);



@interface SBDefaultBannerTextView : NSObject
-(void)setSecondaryTextAlpha:(float)alpha;
@end

@interface SBBannerContainerView : UIView
@end

@interface SBControlCenterContentView : NSObject
@property(nonatomic, assign, readwrite) CGRect frame;
-(void)_iPhone_layoutSubviewsInBounds:(CGRect)bounds orientation:(int)orientation;
@end

static NSDictionary *preferences = nil;
//static BOOL _pulledDown = NO;

static void reloadPreferences() {
	if (preferences) {
		[preferences release];
		preferences = nil;
	}
	
	// Use CFPreferences since sometimes the prefs dont synchronize to the disk immediately
	NSArray *keyList = [(NSArray *)CFPreferencesCopyKeyList((CFStringRef)@"com.atrocity.roundification", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
	preferences = (NSDictionary *)CFPreferencesCopyMultiple((CFArrayRef)keyList, (CFStringRef)@"com.atrocity.roundification", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

//
//	BANNERS
//
%hook SBBannerContainerView
-(void)layoutSubviews
{
	%orig;
	if(ENABLEDBANNERS){
		UIView *banView = MSHookIvar<UIView *>(self, "_bannerView");
		banView.layer.cornerRadius = 15;
		banView.layer.masksToBounds = YES;
		CGFloat width = [UIScreen mainScreen].bounds.size.width;
		CGFloat height = self.frame.size.height;
		[self setFrame:(CGRect){{10,30},{width - 20, height}}];
		banView.frame = (CGRect){{banView.frame.origin.x, banView.frame.origin.y},{self.frame.size.width, banView.frame.size.height}};

		UIView *backdropView = MSHookIvar<UIView *>(self, "_backgroundView");
		backdropView.alpha = 0.0;
	}
}
%end

//
// Notification Center
//
%hook SBNotificationCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 {

	%orig(arg1);

    if (ENABLEDNC){
	    UIViewController *ncViewController = MSHookIvar<UIViewController *>(self, "_viewController");
	   	ncViewController.view.layer.cornerRadius = 20;
	    ncViewController.view.layer.masksToBounds = YES;

	    CGFloat width = [UIScreen mainScreen].bounds.size.width;
	    CGFloat height = [UIScreen mainScreen].bounds.size.height;
	    ncViewController.view.transform = CGAffineTransformIdentity;
	    ncViewController.view.frame = (CGRect){{0,0},{width, height}};
	    ncViewController.view.bounds = (CGRect){{0,0},{width, height}};
		ncViewController.view.transform = CGAffineTransformScale(ncViewController.view.transform, 0.94,0.94);

	    if (!SHOWSTATUS)
	    {
    		UIView *statusbar = MSHookIvar<UIView *>(ncViewController, "_statusBar");
    		statusbar.alpha = 0.0;
    	}

	}
}
%end

//
// Control Center
//
%hook SBControlCenterController
-(void)_beginPresentation
{
	%orig;

	if(ENABLEDCC)
	{
		UIViewController *ccViewController = MSHookIvar<UIViewController *>(self, "_viewController");
		CGFloat width = [UIScreen mainScreen].bounds.size.width;
	    CGRect fr = ccViewController.view.frame;
	    ccViewController.view.frame = (CGRect){{10, -10}, {width - 20, fr.size.height}};

	    UIView * ccContainerView = MSHookIvar<UIView *>(ccViewController,"_containerView");
	    UIView * ccContentContainerView = MSHookIvar<UIView *>(ccContainerView, "_contentContainerView");
	    ccContentContainerView.layer.cornerRadius = 20;
	    ccContentContainerView.layer.masksToBounds = YES;

		UIView * darkView = MSHookIvar<UIView *>(ccContainerView, "_darkeningView");
		darkView.alpha = 0.01;
	}
}
%end

//
// App Switcher Cards
//
%hook SBAppSwitcherPageView
-(void)layoutSubviews
{
	%orig;
	if (ENABLE_APP_CARDS)
	{
		UIView * contentView = MSHookIvar<UIView *>(self, "_view");
		contentView.layer.cornerRadius = 20;
		contentView.layer.masksToBounds = YES;
	}
}
%end

//
// Dock
//
%hook SBRootFolderView
-(void)layoutDockView
{
	%orig;
	if(ENABLEDDOCK)
	{
		CGFloat width = [UIScreen mainScreen].bounds.size.width;
		UIView * dock = MSHookIvar<UIView *>(self, "_dockView");
		dock.layer.cornerRadius = 20;
		dock.layer.masksToBounds = YES;
		dock.frame = (CGRect){{5, dock.frame.origin.y - 5},{width - 10, dock.frame.size.height}};
	}
}
%end

//
//UIAlerts
//
%hook UIAlertControllerVisualStyleActionSheet
-(CGFloat)backgroundCornerRadius
{
	if(ENABLE_UI_ALERT_MENU)
	{	
		return 20.0;
	}
	else
	{
		return %orig;
	}
}
%end

// static void settingschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
//     reloadPreferences();
// }

%ctor {
	//CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingschanged, CFSTR("com.atrocity.roundification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	reloadPreferences();
}