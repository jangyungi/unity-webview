/*
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

using UnityEngine;

public class SampleWebView : MonoBehaviour
{
	public string Url;
	WebViewObject webViewObject;

	void Start()
	{
		
		webViewObject =
			(new GameObject("WebViewObject")).AddComponent<WebViewObject>();
		webViewObject.Init((msg)=>{
			Debug.Log(string.Format("CallFromJS[{0}]", msg));
		},null,null);

		webViewObject.LoadURL(Url);
		webViewObject.SetVisibility(true);
		
		/*
		switch (Application.platform) {
		case RuntimePlatform.OSXEditor:
		case RuntimePlatform.OSXPlayer:
		case RuntimePlatform.IPhonePlayer:
			webViewObject.EvaluateJS(
				"window.addEventListener('load', function() {" +
				"	window.Unity = {" +
				"		call:function(msg) {" +
				"			var iframe = document.createElement('IFRAME');" +
				"			iframe.setAttribute('src', 'unity:' + msg);" +
				"			document.documentElement.appendChild(iframe);" +
				"			iframe.parentNode.removeChild(iframe);" +
				"			iframe = null;" +
				"		}" +
				"	}" +
				"}, false);");
			break;
		}
		
		webViewObject.EvaluateJS(
			"window.addEventListener('load', function() {" +
			"	window.addEventListener('click', function() {" +
			"		Unity.call('clicked');" +
			"	}, false);" +
			"}, false);");
		*/
	}
}
