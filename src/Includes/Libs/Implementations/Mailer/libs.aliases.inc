{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * redeclare all class types in unit inside Libs/Mailer
 * directory
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)
TAbstractMailer = AbstractMailerImpl.TAbstractMailer;

TSendmailMailer = SendmailMailerImpl.TSendmailMailer;
TSendmailMailerFactory = SendmailMailerFactoryImpl.TSendmailMailerFactory;

{$IFDEF USE_SYNAPSE}
TSynapseMailer = SynapseMailerImpl.TSynapseMailer;
TSynapseMailerFactory = SynapseMailerFactoryImpl.TSynapseMailerFactory;
{$ENDIF}

{$IFDEF USE_INDY}
TIndyMailer = IndyMailerImpl.TIndyMailer;
TIndyMailerFactory = IndyMailerFactoryImpl.TIndyMailerFactory;
{$ENDIF}
