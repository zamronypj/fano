{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CspConstant;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * configuration for Content Security Policy
     *-------------------------------------------------
     * https://www.w3.org/TR/CSP/
     * https://content-security-policy.com/
     * https://web.dev/csp/
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCspConfig = record
        // default URLs to use when any config below unspecified.
        defaultSrc: string;

        // restricts the URLs that can appear in a page's <base> element.
        baseUri: string;

        // restricts the URLs that can appear in a page's <script> element.
        scriptSrc: string;

        // lists the URLs for workers and embedded frame contents.
        // Example: child-src https://youtube.com would enable embedding videos
        // from YouTube but not from other origins.
        childSrc: string;

        // restricts the URLs that can connect to XHR, WebSocket, EventSource.
        connectSrc: string;

        // restricts the URLs that can serve page's font resources.
        fontSrc: string;

        // restricts the URLs that can serve page's image resources.
        imgSrc: string;

        // restricts the URLs that can be used in <form> action submission.
        formAction: string;

        // restricts the URLs that can embed current page.
        frameAncestors: string;

        // restricts the URLs that can be used in page's <frame> element.
        frameSrc: string;

        // restricts the URLs that can be used in audio video resources.
        mediaSrc: string;

        // restricts the URLs that can be used in pages's <link> stylesheets.
        styleSrc: string;

        // restricts the URLs that can be used in page's Flash element or plugins.
        objectSrc: string;

        // restricts the plugin type that can be used in page.
        pluginTypes: string;

        // set URL which browser send report when CSP violated.
        reportUri: string;

        // restricts the URLs that can be used in page's service worker.
        workerSrc: string;

        // upgrade http to https.
        upgradeInsecureRequests: boolean;
    end;

const

    // constant for CSP source list

    // Match none
    CSP_NONE = '''none''';

    // Match current origin but not subdomains
    CSP_SELF = '''self''';

    // Allow inline JS and CSS
    CSP_UNSAFE_INLINE = '''unsafe-inline''';

    // Allow evaluation of text to JavaScript such as eval()
    CSP_UNSAFE_EVAL = '''unsafe-eval''';


implementation

end.
