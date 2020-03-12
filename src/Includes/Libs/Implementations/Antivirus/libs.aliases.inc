{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

{------------ Begin ClamAV antivirus related------------------}
{$IFDEF LIBCLAMAV}
TClamAv = ClamAvImpl.TClamAv;
{$ENDIF}
EClamAv = EClamAvImpl.EClamAv;
TLocalClamdAv = LocalClamdAvImpl.TClamdAv;
{------------ End ClamAV antivirus related------------------}

TNullAv = NullAvImpl.TNullAv;
