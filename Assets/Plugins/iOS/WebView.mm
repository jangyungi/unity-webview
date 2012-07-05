/*
 * Copyright (C) 2011 Keijiro Takahashi
 * Copyright (C) 2012 GREE, Inc.
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

/*
 * Modified by Jang Yungi, July 2012
 * This is derived from imkira's folk version.
 */

#import <UIKit/UIKit.h>

extern UIViewController *UnityGetGLViewController();

@interface WebViewPlugin : NSObject<UIWebViewDelegate>
{
	UIWebView *webView;
	NSString *gameObjectName;
}
@end

@implementation WebViewPlugin

- (id)initWithGameObjectName:(const char *)gameObjectName_
{
	self = [super init];

	UIView *view = UnityGetGLViewController().view;
	webView = [[UIWebView alloc] initWithFrame:view.frame];
	webView.delegate = self;
	webView.hidden = YES;
	[view addSubview:webView];
	gameObjectName = [[NSString stringWithUTF8String:gameObjectName_] retain];

	return self;
}

- (void)dealloc
{
	[webView removeFromSuperview];
	[webView release];
	[gameObjectName release];
}

#pragma mark Webview Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *url = [[request URL] absoluteString];
	if ([url hasPrefix:@"dof:/"]) {
		UnitySendMessage([gameObjectName UTF8String],"CallFromJS", [[url substringFromIndex:5] UTF8String]);
		return NO;
	} else {
        [self addMaskView];
		return YES;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //Do nothing
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UnitySendMessage([gameObjectName UTF8String], "OnFinishedWebLoading", "");
    [self removeMaskView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UnitySendMessage([gameObjectName UTF8String], "OnFailedWebLoading", "");
}

#pragma mark Hiding Mask

- (void)addMaskView
{
    if([webView viewWithTag:1]==nil)
    {
        UIView* paperView = [[UIView alloc] initWithFrame:_webView.frame];
        paperView.backgroundColor =[UIColor blackColor];
        paperView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [webView addSubview:paperView];
        paperView.tag=1;
        [paperView release];
    }
}

- (void)removeMaskView
{
    if([webView viewWithTag:1]!=nil) [[webView viewWithTag:1] removeFromSuperview];
}

#pragma mark Webview Methods

- (void)setMargins:(int)left top:(int)top right:(int)right bottom:(int)bottom
{
	UIView *view = UnityGetGLViewController().view;

	CGRect frame = view.frame;
	CGFloat scale = view.contentScaleFactor;
	frame.size.width -= (left + right) / scale;
	frame.size.height -= (top + bottom) / scale;
	frame.origin.x += left / scale;
	frame.origin.y += top / scale;
	webView.frame = frame;
}

- (void)setVisibility:(BOOL)visibility
{
	webView.hidden = visibility ? NO : YES;
}

- (void)loadURL:(const char *)url
{
	[self loadURL:url withArgs:nil];
}

- (void)loadURL:(const char *)url withArgs:(const char *)args
{
    NSString *urlStr = [NSString stringWithUTF8String:url];
    
    if(args !=nil)
    {
        NSString *argsStr = [NSString stringWithUTF8String:args];
        NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[argsStr dataUsingEncoding:NSUTF8StringEncoding]];
        [webView loadRequest:request];
    }
    else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [webView loadRequest:request];
    }
}

- (void)evaluateJS:(const char *)js
{
	NSString *jsStr = [NSString stringWithUTF8String:js];
	[webView stringByEvaluatingJavaScriptFromString:jsStr];
}

@end

extern "C" {
	void *_WebViewPlugin_Init(const char *gameObjectName);
	void _WebViewPlugin_Destroy(void *instance);
	void _WebViewPlugin_SetMargins(void *instance, int left, int top, int right, int bottom);
	void _WebViewPlugin_SetVisibility(void *instance, BOOL visibility);
	void _WebViewPlugin_LoadURL(void *instance, const char *url);
    void _WebViewPlugin_LoadURL_Args(void *instance, const char *url, const char* args);
	void _WebViewPlugin_EvaluateJS(void *instance, const char *url);
    char *_WebViewPluginPollMessage();
}

void *_WebViewPlugin_Init(const char *gameObjectName)
{
	id instance = [[WebViewPlugin alloc] initWithGameObjectName:gameObjectName];
	return (void *)instance;
}

void _WebViewPlugin_Destroy(void *instance)
{
	WebViewPlugin *webViewPlugin = (WebViewPlugin *)instance;
	[webViewPlugin release];
}

void _WebViewPlugin_SetMargins(
	void *instance, int left, int top, int right, int bottom)
{
	WebViewPlugin *webViewPlugin = (WebViewPlugin *)instance;
	[webViewPlugin setMargins:left top:top right:right bottom:bottom];
}

void _WebViewPlugin_SetVisibility(void *instance, BOOL visibility)
{
	WebViewPlugin *webViewPlugin = (WebViewPlugin *)instance;
	[webViewPlugin setVisibility:visibility];
}

void _WebViewPlugin_LoadURL(void *instance, const char *url)
{
	WebViewPlugin *webViewPlugin = (WebViewPlugin *)instance;
	[webViewPlugin loadURL:url];
}

void _WebViewPlugin_LoadURL_Args(void *instance, const char *url, const char* args)
{
    WebViewPlugin *webViewPlugin = (WebViewPlugin *)instance;
	[webViewPlugin loadURL:url withArgs:args];
}
void _WebViewPlugin_EvaluateJS(void *instance, const char *js)
{
	WebViewPlugin *webViewPlugin = (WebViewPlugin *)instance;
	[webViewPlugin evaluateJS:js];
}

char *_WebViewPluginPollMessage()
{
    NSString *message = [webView stringByEvaluatingJavaScriptFromString:@"unityWebMediatorInstance.pollMessage()"];
    if (message && message.length > 0) {
        NSLog(@"UnityWebViewPlugin: %@", message);
        char* memory = static_cast<char*>(malloc(strlen(message.UTF8String) + 1));
        if (memory) strcpy(memory, message.UTF8String);
        return memory;
    } else {
        return NULL;
    }
}
