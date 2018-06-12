# Ovatar-iOS Documentation
<strong>Ovatar</strong> is the quickest and most powerful way to enable avatar support in any client. This documentation focuses on the iOS framework build in Objective C, but can be used in both Objective C and Swift projects. In this documentation, we will show you how to get avatar support in your app in minutes with our super simplified classes that require only a small amount of code. But we also will go into more detail as this framework can give you full control of all Ovatar features. Let's begin…<p>

<h3>Registering</h3>
To begin using Ovatar in any project you must first obtain a <strong>app key</strong>. <strike>This can be done by first signing up to Ovatar at <a href='https://ovatar.io'>ovatar.io</a> then creating an app.</strike>Right now we are still building the dashboard so please contact us directly for an app key. <p>
    
<strong>NOTE</strong> Ovatar is still in BETA so please let us know of any issues, also be aware that some aspects of the framework may change without notice. For this, we suggest using coccopods version control. 

<h3>Setup</h3>
Ovatar can be installed manually by downloading the repo and adding all the <code<OOvatar</code> & <code<>OOvatarIcon</code> header and implementation files.<p><p>
<strong>OR</strong><p>
by adding adding the project though <strong>Coccopods</strong> (Recommended)<p> <code>pod 'Ovatar-iOS'</code><p>

<h3>Getting Started</h3>
<pre>
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[OOvatar sharedInstanceWithAppKey:@"app_key"];
    [[OOvatar sharedInstance] setDebugging:true];
    
    return true;

}</pre><p>

<h3>Ovatar Icon (The Easy Way)</h3>
To make it quick and easy to get ovatar up and running in your app we designed the <strong>OOvatarIcon</strong>. This is a powerful class that handles...<p>
<li>downloading images from a key or query (email or phone number)</li>
<li>image caching</li>
<li>automatic image repositioning and sizing</li>
<li>face detection</li>
<li>image selection and uploading with progress</li>
<li>fullscreen previews</li>
<li>image size management</li>

<p><p><p><p>

<h3>Adding the OvatarIcon</h3>
in your <code>.h</code> add the <strong>OOvatarIcon</strong> framework<p><p>
<code>#import "OOvatarIcon/OOvatarIcon.h" </code>
<p><code>@property (nonatomic, strong) OOvatarIcon *ovatar;</code><p>

Then, in your <code>.m</code>
<pre>
     self.ovatar = [[OOvatarIcon alloc] initWithFrame:CGRectMake((self.bounds.size.width / 2) - 100.0, (self.bounds.size.height / 2) - 100.0, 200.0, 200.0)];
     self.ovatar.placeholder = [UIImage imageNamed:@"a_custom_placeholder_image"];
     self.ovatar.oicondelegate = self;
     self.ovatar.hasaction = true;
     self.ovatar.preview = false;    
     self.ovatar.allowsphotoediting = true;
     self.ovatar.onlyfaces = false;     
     [self addSubview:self.headerOvatar];
          
</pre>

<h3>Let's get that Ovatar!</h3>
<h5>Querying by Key, Email Address or Phone Number</h5><p>
Ovatar allows you to query of course images uploaded using your app_key can be called with ease (the use of a key) but you can also query Ovatar images by <strong>Email Address</strong> or <strong>Phone Number</strong> and all can be achived by calling<p><p><code>[self.ovatar imageDownloadWithQuery:@"user@email.com"];</code><p>

<strong>NOTE</strong> If you want to query both a key and a email address as fall back simply add this method multiple times.<p>
	<pre>
		[self.ovatar imageDownloadWithQuery:@"user@email.com"];  //email address query
		[self.ovatar imageDownloadWithQuery:@"+44000000000000"];  //uk phone number query
		[self.ovatar imageDownloadWithQuery:@"my_uploaded_ovatar_key"]; //query by key
	</pre>
By default the class will load the images by key over query. <p><p>
<strong>NOTE</strong> Some users have reported this not working, this is because they called this before the <strong>OOvatarIcon</strong> was initialized. Please make sure you add <strong>OOvatarIcon</strong> to your project <strong>first!</strong>

<h5>Setting your own icon</h5><p>
In some cases you may have an avatar icon from another service you would like to use. To do so you can just call
<pre>
[self.ovatar imageSet:[UIImage imageNamed:@"my_local_image.png"] animated:TRUE]
</pre>

<h5>Manual Uploading</h5>
We advise using the power of the <strong>OOvatarIcon</strong> class for selecting, managing and uploading new images but if you do wish to upload an image manually you can do so by calling.  
<pre>
NSData *imagedata = UIImageJPEGRepresentation([UIImage imageNamed:@"my_selected_image.jpg"], 0.8);
NSDictionary *metadata = @{@"copyright":@"joe barbour"};
[self.ovatar imageUpdateWithImage:imagedata info:nil];
</pre>

<strong>NOTE</strong> Metadata is returned by querying the JSON output</strong>

<p><p><p><p>

<h3>The Power of the OOvatarIcon</h3>
<h5>Placeholder</h5>A placeholder image can be set be set if there is no image available. This can be done by setting the placeholder as a <strong>UIImage</strong>. If this is not set the default ovatar placeholder will be set, but this done via a remote image request. We recommend setting your own placeholder to match your UI to avoid any empty states.<p>
    
<h5>Editing</h5>there will be occasions in your app where you will want to allow the user to edit/change their avatar and there will be times where you don't. By default, the user will not be able to interact with an image. But you can change this by setting the <code>self.ovatar.hasaction = true;</code>. When set to <strong>TRUE</strong>, tapping on the <strong>OOvatarIcon</strong> will either call the <code>ovatarIconWasTappedWithGesture</code> delegate method (see more about delegate callbacks below) or launch the default iOS Gallery Picker right from the subview. By default, the Gallery Picker will be presented, but this can be disabled by setting <code>self.ovatar.presentpicker = false;</code>

<h5>Only Faces</h5>
    Let's say you're building a dating app? Then you won't want your users to have photos of their dog or their holiday, you want accurate photos of that person. By setting <code>self.ovatar.onlyfaces = true;</code> the class will quickly detect if the selected image indeed has a human face within. If it does then the image will be uploaded but if the user selects an image without a face then the <code>ovatarIconUploadFailedWithErrors</code> will be called with an <strong>NSError</strong>. (see below for more information about delegate callbacks)

<h5>Image Editing</h5>
    Images sizes are managed by Ovatar directly but cropping is not (currently). To make this easy you can set <code>self.ovatar.allowsphotoediting = true;</code> and when the user selects an image from the default iOS Gallery Picker they will be presented with the default iOS cropping tool. Here the user can resize and reposition the image as they see fit. By default this is disabled. 
    
<h5>Animation</h5>
OOvatarIcon uses low level animations such as crossfades for when new images are loaded and scale 'bounces' when the icon is tapped. All these animations can be disabled by calling <code>self.ovatar.animated = false;</code><p><p>
Additionally, for more control you can change the crossfade duration by setting <code>self.ovatar.crossfade = 1.0;</code>. By deafult this is 0.6.

<h5>Full Preview</h5>Sometimes ovatar images maybe just there as a reference point and maybe to small to see. Enabling preview means when the user taps on an image they will be able to see the Ovatar in full screen. Here a higher resolution will be automatically loaded. This can be enabled on any <strong>OOvatarIcon</strong> that is not editable (<code>self.ovatar.hasaction = true;</code>). By default this is disabled, but can be enabled by <code>self.ovatar.preview = true;</code><p>
Additionally, you can set a custom caption in the full-screen view. This could be information about the user or just about anything. To add this setting <code>self.ovatar.previewcaption = @"This is my Ovatar Caption"</code>
    
<h5>Delegate Callbacks</h5>
For more precice control the OvatarIcon has 4 delegate callbacks. To enable these you must declare the OOvatarIcon as a delegate by <code>self.ovatar.oicondelegate = self;</code>
<p>
<pre>
    -(void)ovatarIconWasTappedWithGesture:(UITapGestureRecognizer *)gesture {
        //Called if the 'presentpicker' BOOL is set to FALSE (by default it is set to TRUE). Here you can set custom actions for the when the Ovatar Icon is tapped.
    }
    
</pre>
<p>
<pre>
    -(void)ovatarIconWasUpdatedSucsessfully:(NSDictionary *)output {
        //Called if an image is uploaded successfully.
    }
</pre>
<p>
<pre>
    -(void)ovatarIconUploadFailedWithErrors:(NSError *)error {
        //Called if an image cannot be uploaded, see the documentation for error codes.
    }
</pre>
<p>
<pre>
    -(void)ovatarIconUploadingWithProgress:(float)progress {
        //Called everytime the progress of the upload changes. The progress with displayed as in double value on a 0-100 scale.
    }
</pre>
<p><p>
<p><p>

<h3>Debugging & Options</h3>
The following can be set from anywhere in your app but we recommend setting the following variables in the <code>didFinishLaunchingWithOptions</code> method in your <codeAppDelegate.m</code><p><p>
<h5>Debugging</h5> to enable console debugging simply set 
<code>[[OOvatar sharedInstance] setDebugging:true];</code><p>
<h5><a href=“http://gravatar.com”>Gravatar</a> Support</h5> by default if an avatar cannot be found Ovatar will attempt to fallback on Gravatar. This can be disabled. 
<code>[[OOvatar sharedInstance] setGravatarFallback:false];</code><p><p>
<h5>Caching</h5> When an ovatar image is initially downloaded it is saved ti the local cache. This it to prevent unnecessary server calls. The caching cannot be disabled but the expiry can be changed by setting <code>[[OOvatar sharedInstance] setCacheExpirySeconds:60*60*4];</code> (this is in seconds)



    



