{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
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
SlugValidatorImpl,
PhoneValidatorImpl,
MacAddrValidatorImpl,
ColorValidatorImpl,

BaseCompositeValidatorImpl,
CompositeValidatorImpl,
CollectiveValidatorImpl,
AndValidatorImpl,
OrValidatorImpl,
AnyOfValidatorImpl,

IntegerValidatorImpl,
Int64ValidatorImpl,
DwordValidatorImpl,
QwordValidatorImpl,
MaxIntegerValidatorImpl,
MinIntegerValidatorImpl,
EvenIntValidatorImpl,
OddIntValidatorImpl,
PositiveIntValidatorImpl,
NegativeIntValidatorImpl,
InIntValidatorImpl,
CompareIntValidatorImpl,
EqualIntValidatorImpl,
LessThanValidatorImpl,
GreaterThanValidatorImpl,
LessOrEqualThanValidatorImpl,
GreaterOrEqualThanValidatorImpl,
BetweenValidatorImpl,

CompareFloatValidatorImpl,
FloatLessThanValidatorImpl,
FloatGreaterThanValidatorImpl,
FloatLessOrEqualThanValidatorImpl,
FloatGreaterOrEqualThanValidatorImpl,
FloatBetweenValidatorImpl,

CompareCurrencyValidatorImpl,
CurrLessThanValidatorImpl,
CurrGreaterThanValidatorImpl,
CurrLessOrEqualThanValidatorImpl,
CurrGreaterOrEqualThanValidatorImpl,
CurrBetweenValidatorImpl,

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
AfterDateTimeFieldValidatorImpl,
BeforeDateTimeFieldValidatorImpl,
UuidValidatorImpl,
Base64ValidatorImpl,
MinLengthValidatorImpl,
MaxLengthValidatorImpl,
EqualLengthValidatorImpl,
UploadedFileValidatorImpl,
UploadedMimeValidatorImpl,
UploadedSizeValidatorImpl,
NotValidatorImpl,
AlwaysPassValidatorImpl,
CompareFieldValidatorImpl,
ExistsValidatorImpl,
AntivirusValidatorImpl,

FileFormatValidatorImpl,
ImagePngValidatorImpl,
ImageJpgValidatorImpl,
ImageGifValidatorImpl,

Ipv4ValidatorImpl,
Ipv6ValidatorImpl,

JsonValidatorImpl,

FileValidatorImpl,
DirectoryValidatorImpl,

CompareStrValidatorImpl,
EqualStrValidatorImpl,
CaseInsensitiveEqualStrValidatorImpl,

StartWithValidatorImpl,
EndWithValidatorImpl,

LatitudeValidatorImpl,
LongitudeValidatorImpl,

AtLeastOneAlphaValidatorImpl,
AtLeastOneDigitValidatorImpl,
AtLeastOneLowerAlphaValidatorImpl,
AtLeastOneUpperAlphaValidatorImpl,
AtLeastOneSymbolValidatorImpl,
MixedCapsValidatorImpl,
