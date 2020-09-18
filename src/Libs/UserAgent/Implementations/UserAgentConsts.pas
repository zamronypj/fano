{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UserAgentConsts;

interface

{$MODE OBJFPC}
{$H+}


const

    (*!------------------------------------------------
     * constant related to browser, OS identification
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * @credit https://github.com/serbanghita/Mobile-Detect
     *-----------------------------------------------*)

    REGEX_VER = '([\w._\+]+)';

    REGEX_CHROME = '\bCrMo\b|CriOS|Android.*Chrome/[.0-9]* (Mobile)?';
    REGEX_FIREFOX = 'fennec|firefox.*maemo|(Mobile|Tablet).*Firefox|Firefox.*Mobile|FxiOS';
    REGEX_SAFARI = 'Version.*Mobile.*Safari|Safari.*Mobile|MobileSafari';
    REGEX_EDGE = 'Mobile Safari/[.0-9]* Edge';
    REGEX_OPERA = 'Opera.*Mini|Opera.*Mobi|Android.*Opera|Mobile.*OPR/[0-9.]+$|Coast/[0-9.]+';
    REGEX_IE = 'IEMobile|MSIEMobile';
    REGEX_GENERIC = 'NokiaBrowser|OviBrowser|OneBrowser|TwonkyBeamBrowser|SEMC.*Browser|FlyFlow|Minimo|NetFront|Novarra-Vision|MQQBrowser|MicroMessenger';
    REGEX_DOLFIN = '\bDolfin\b';
    REGEX_SKYFIRE = 'Skyfire';
    REGEX_BOLT = 'bolt';
    REGEX_UCBROWSER = 'UC.*Browser|UCWEB';
    REGEX_BAIDU = 'baidubrowser';
    REGEX_TEASHARK = 'teashark';
    REGEX_BLAZER = 'Blazer';
    REGEX_WECHAT = '\bMicroMessenger\b';

    BROWSER_CHROME = 'Chrome';
    BROWSER_FIREFOX = 'Firefox';
    BROWSER_SAFARI = 'Safari';
    BROWSER_EDGE = 'Edge';
    BROWSER_OPERA = 'Opera';
    BROWSER_IE = 'IE';
    BROWSER_GENERIC = 'GenericBrowser';
    BROWSER_DOLFIN = 'Dolfin';
    BROWSER_SKYFIRE = 'Skyfire';
    BROWSER_BOLT = 'Bolt';
    BROWSER_UCBROWSER = 'UCBrowser';
    BROWSER_BAIDU = 'baidubrowser';
    BROWSER_TEASHARK = 'TeaShark';
    BROWSER_BLAZER = 'Blazer';
    BROWSER_WECHAT = 'WeChat';


    //OS-related constant
    REGEX_ANDROID = 'Android';
    REGEX_BLACKBERRY = 'blackberry|\bBB10\b|rim tablet os';
    REGEX_IOS = '\biPhone.*Mobile|\biPod|\biPad|AppleCoreMedia';
    REGEX_PALMOS = 'PalmOS|avantgo|blazer|elaine|hiptop|palm|plucker|xiino';
    REGEX_SYMBIAN = 'Symbian|SymbOS|Series60|Series40|SYB-[0-9]+|\bS60\b';
    REGEX_WINDOWS_MOBILE = 'Windows CE.*(PPC|Smartphone|Mobile|[0-9]{3}x[0-9]{3})|Windows Mobile|Windows Phone [0-9.]+|WCE;';
    REGEX_WINDOWS_PHONE = 'Windows Phone 10.0|Windows Phone 8.1|Windows Phone 8.0|Windows Phone OS|XBLWP7|ZuneWP7|Windows NT 6.[23]; ARM;';
    REGEX_JAVA = 'J2ME/|\bMIDP\b|\bCLDC\b';
    REGEX_WEBOS = 'webOS|hpwOS';

    OS_ANDROID = 'AndroidOS';
    OS_BLACKBERRY = 'BlackBerryOS';
    OS_IOS = 'iOS';
    OS_PALMOS = 'PalmOS';
    OS_SYMBIAN = 'SymbianOS';
    OS_WINDOWS_MOBILE = 'WindowsMobileOS';
    OS_WINDOWS_PHONE = 'WindowsPhoneOS';
    OS_JAVA = 'JavaOS';
    OS_WEBOS = 'webOS';

implementation
end.
