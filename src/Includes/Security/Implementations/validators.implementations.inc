{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * list of validator rule units for security
 * that is included in implementations.inc
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)


BaseValidatorImpl,
AlphaNumValidatorImpl,
AlphaNumSpaceValidatorImpl,
AlphaNumDashValidatorImpl,
AlphaValidatorImpl,

BaseCompositeValidatorImpl,
CompositeValidatorImpl,
CollectiveValidatorImpl,

IntegerValidatorImpl,
MaxIntegerValidatorImpl,
MinIntegerValidatorImpl,
RegexValidatorImpl,
RequiredValidatorImpl,
RequiredIfValidatorImpl,
EmailValidatorImpl,
UrlValidatorImpl,
FloatValidatorImpl,
NumericValidatorImpl,
CurrencyValidatorImpl,
InValidatorImpl,
NotInValidatorImpl,
BooleanValidatorImpl,
AcceptedValidatorImpl,
ConfirmedValidatorImpl,
SameValidatorImpl,
PresentValidatorImpl,
DateValidatorImpl,
TimeValidatorImpl,
DateTimeValidatorImpl,
CompareDateTimeValidatorImpl,
AfterDateTimeValidatorImpl,
BeforeDateTimeValidatorImpl,
EqualDateTimeValidatorImpl,
UuidValidatorImpl,
MinLengthValidatorImpl,
MaxLengthValidatorImpl,
EqualLengthValidatorImpl,
UploadedFileValidatorImpl,
UploadedMimeValidatorImpl,
UploadedSizeValidatorImpl,
NotValidatorImpl,
AlwaysPassValidatorImpl,
