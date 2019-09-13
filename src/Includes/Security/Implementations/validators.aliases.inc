{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * alias for validators implementation in security
 * that is included in validations.aliases.inc
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)

TBaseValidator = BaseValidatorImpl.TBaseValidator;
TRegexValidator = RegexValidatorImpl.TRegexValidator;

TAlphaNumSpaceValidator = AlphaNumSpaceValidatorImpl.TAlphaNumSpaceValidator;
TAlphaNumValidator = AlphaNumValidatorImpl.TAlphaNumValidator;
TAlphaNumDashValidator = AlphaNumDashValidatorImpl.TAlphaNumDashValidator;
TAlphaValidator = AlphaValidatorImpl.TAlphaValidator;
TEmailValidator = EmailValidatorImpl.TEmailValidator;

TCompositeValidator = CompositeValidatorImpl.TCompositeValidator;

TIntegerValidator = IntegerValidatorImpl.TIntegerValidator;
TMinIntegerValidator = MinIntegerValidatorImpl.TMinIntegerValidator;
TMaxIntegerValidator = MaxIntegerValidatorImpl.TMaxIntegerValidator;

TFloatValidator = FloatValidatorImpl.TFloatValidator;
TNumericValidator = NumericValidatorImpl.TNumericValidator;
TCurrencyValidator = CurrencyValidatorImpl.TCurrencyValidator;

TInValidator = InValidatorImpl.TInValidator;
TNotInValidator = NotInValidatorImpl.TNotInValidator;

TBooleanValidator = BooleanValidatorImpl.TBooleanValidator;
TAcceptedValidator = AcceptedValidatorImpl.TAcceptedValidator;
TConfirmedValidator = ConfirmedValidatorImpl.TConfirmedValidator;

TRequiredValidator = RequiredValidatorImpl.TRequiredValidator;
TPresentValidator = PresentValidatorImpl.TPresentValidator;

TDateValidator = DateValidatorImpl.TDateValidator;
TTimeValidator = TimeValidatorImpl.TTimeValidator;
TDateTimeValidator = DateTimeValidatorImpl.TDateTimeValidator;
TCompareDateTimeValidator = CompareDateTimeValidatorImpl.TCompareDateTimeValidator;
TAfterDateTimeValidator = AfterDateTimeValidatorImpl.TAfterDateTimeValidator;
TBeforeDateTimeValidator = BeforeDateTimeValidatorImpl.TBeforeDateTimeValidator;
TEqualDateTimeValidator = EqualDateTimeValidatorImpl.TEqualDateTimeValidator;

TUuidValidator = UuidValidatorImpl.TUuidValidator;

TMinLengthValidator = MinLengthValidatorImpl.TMinLengthValidator;
TMaxLengthValidator = MaxLengthValidatorImpl.TMaxLengthValidator;
TEqualLengthValidator = EqualLengthValidatorImpl.TEqualLengthValidator;

TUploadedFileValidator = UploadedFileValidatorImpl.TUploadedFileValidator;
TUploadedMimeValidator = UploadedMimeValidatorImpl.TUploadedMimeValidator;
TUploadedSizeValidator = UploadedSizeValidatorImpl.TUploadedSizeValidator;
