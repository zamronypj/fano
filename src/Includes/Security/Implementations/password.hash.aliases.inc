{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * alias for implementation in security
 * that is included in implementations.aliases.inc
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)
TPbkdf2PasswordHash = Pbkdf2PasswHashImpl.TPbkdf2PasswordHash;
TPbkdf2PasswordHashFactory = Pbkdf2PasswHashFactoryImpl.TPbkdf2PasswordHashFactory;

TArgon2iPasswHash = Argon2iPasswHashImpl.TArgon2iPasswHash;
TArgon2iPasswHashFactory = TArgon2iPasswHashFactoryImpl.TArgon2iPasswHashFactory;

TSha2_256PasswHash = Sha2_256PasswHashImpl.TSha2_256PasswHash;
TSha2_512PasswHash = Sha2_512PasswHashImpl.TSha2_512PasswHash;
TSha2PasswHashFactory = Sha2PasswHashFactoryImpl.TSha2PasswHashFactory;
