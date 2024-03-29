{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
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
TUrlValidator = UrlValidatorImpl.TUrlValidator;
TSlugValidator = SlugValidatorImpl.TSlugValidator;
TPhoneValidator = PhoneValidatorImpl.TPhoneValidator;
TMacAddrValidator = MacAddrValidatorImpl.TMacAddrValidator;
TColorValidator = ColorValidatorImpl.TColorValidator;

TBaseCompositeValidator = BaseCompositeValidatorImpl.TBaseCompositeValidator;
TCompositeValidator = CompositeValidatorImpl.TCompositeValidator;
TCollectiveValidator = CollectiveValidatorImpl.TCollectiveValidator;
TAndValidator = AndValidatorImpl.TAndValidator;
TOrValidator = OrValidatorImpl.TOrValidator;
TAnyOfValidator = AnyOfValidatorImpl.TAnyOfValidator;

TIntegerValidator = IntegerValidatorImpl.TIntegerValidator;
TInt64Validator = Int64ValidatorImpl.TInt64Validator;
TDwordValidator = DwordValidatorImpl.TDwordValidator;
QwordValidator = QwordValidatorImpl.TQwordValidator;
TMinIntegerValidator = MinIntegerValidatorImpl.TMinIntegerValidator;
TMaxIntegerValidator = MaxIntegerValidatorImpl.TMaxIntegerValidator;
TEvenIntValidator = EvenIntValidatorImpl.TEvenIntValidator;
TOddIntValidator = OddIntValidatorImpl.TOddIntValidator;
TPositiveIntValidator = PositiveIntValidatorImpl.TPositiveIntValidator;
TNegativeIntValidator = NegativeIntValidatorImpl.TNegativeIntValidator;
TInIntValidator = InIntValidatorImpl.TInIntValidator;
TCompareIntValidator = CompareIntValidatorImpl.TCompareIntValidator;
TEqualIntValidator = EqualIntValidatorImpl.TEqualIntValidator;
TLessThanValidator = LessThanValidatorImpl.TLessThanValidator;
TGreaterThanValidator = GreaterThanValidatorImpl.TGreaterThanValidator;
TLessOrEqualThanValidator = LessOrEqualThanValidatorImpl.TLessOrEqualThanValidator;
TGreaterOrEqualThanValidator = GreaterOrEqualThanValidatorImpl.TGreaterOrEqualThanValidator;
TBetweenValidator = BetweenValidatorImpl.TBetweenValidator;

TCompareFloatValidator = CompareFloatValidatorImpl.TCompareFloatValidator;
TFloatLessThanValidator = FloatLessThanValidatorImpl.TFloatLessThanValidator;
TFloatGreaterThanValidator = FloatGreaterThanValidatorImpl.TFloatGreaterThanValidator;
TFloatLessOrEqualThanValidator = FloatLessOrEqualThanValidatorImpl.TFloatLessOrEqualThanValidator;
TFloatGreaterOrEqualThanValidator = FloatGreaterOrEqualThanValidatorImpl.TFloatGreaterOrEqualThanValidator;
TFloatBetweenValidator = FloatBetweenValidatorImpl.TFloatBetweenValidator;

TCompareCurrencyValidator = CompareCurrencyValidatorImpl.TCompareCurrencyValidator;
TCurrLessThanValidator = CurrLessThanValidatorImpl.TCurrLessThanValidator;
TCurrGreaterThanValidator = CurrGreaterThanValidatorImpl.TCurrGreaterThanValidator;
TCurrLessOrEqualThanValidator = CurrLessOrEqualThanValidatorImpl.TCurrLessOrEqualThanValidator;
TCurrGreaterOrEqualThanValidator = CurrGreaterOrEqualThanValidatorImpl.TCurrGreaterOrEqualThanValidator;
TCurrBetweenValidator = CurrBetweenValidatorImpl.TCurrBetweenValidator;

TFloatValidator = FloatValidatorImpl.TFloatValidator;
TNumericValidator = NumericValidatorImpl.TNumericValidator;
TCurrencyValidator = CurrencyValidatorImpl.TCurrencyValidator;

TInValidator = InValidatorImpl.TInValidator;
TNotInValidator = NotInValidatorImpl.TNotInValidator;

TBooleanValidator = BooleanValidatorImpl.TBooleanValidator;
TAcceptedValidator = AcceptedValidatorImpl.TAcceptedValidator;
TConfirmedValidator = ConfirmedValidatorImpl.TConfirmedValidator;
TSameValidator = SameValidatorImpl.TSameValidator;

TRequiredValidator = RequiredValidatorImpl.TRequiredValidator;
TRequiredIfValidator = RequiredIfValidatorImpl.TRequiredIfValidator;
TPresentValidator = PresentValidatorImpl.TPresentValidator;

TDateValidator = DateValidatorImpl.TDateValidator;
TTimeValidator = TimeValidatorImpl.TTimeValidator;
TDateTimeValidator = DateTimeValidatorImpl.TDateTimeValidator;
TCompareDateTimeValidator = CompareDateTimeValidatorImpl.TCompareDateTimeValidator;
TAfterDateTimeValidator = AfterDateTimeValidatorImpl.TAfterDateTimeValidator;
TBeforeDateTimeValidator = BeforeDateTimeValidatorImpl.TBeforeDateTimeValidator;
TEqualDateTimeValidator = EqualDateTimeValidatorImpl.TEqualDateTimeValidator;
TAfterDateTimeFieldValidator = AfterDateTimeFieldValidatorImpl.TAfterDateTimeFieldValidator;
TBeforeDateTimeFieldValidator = BeforeDateTimeFieldValidatorImpl.TBeforeDateTimeFieldValidator;

TUuidValidator = UuidValidatorImpl.TUuidValidator;
TBase64Validator = Base64ValidatorImpl.TBase64Validator;

TMinLengthValidator = MinLengthValidatorImpl.TMinLengthValidator;
TMaxLengthValidator = MaxLengthValidatorImpl.TMaxLengthValidator;
TEqualLengthValidator = EqualLengthValidatorImpl.TEqualLengthValidator;

TUploadedFileValidator = UploadedFileValidatorImpl.TUploadedFileValidator;
TUploadedMimeValidator = UploadedMimeValidatorImpl.TUploadedMimeValidator;
TUploadedSizeValidator = UploadedSizeValidatorImpl.TUploadedSizeValidator;

TNotValidator = NotValidatorImpl.TNotValidator;
TAlwaysPassValidator = AlwaysPassValidatorImpl.TAlwaysPassValidator;
TCompareFieldValidator = CompareFieldValidatorImpl.TCompareFieldValidator;
TExistsValidator = ExistsValidatorImpl.TExistsValidator;
TAntivirusValidator = AntivirusValidatorImpl.TAntivirusValidator;

TFileFormatValidator = FileFormatValidatorImpl.TFileFormatValidator;
TImagePngValidator = ImagePngValidatorImpl.TImagePngValidator;
TImageJpgValidator = ImageJpgValidatorImpl.TImageJpgValidator;
TImageGifValidator = ImageGifValidatorImpl.TImageGifValidator;

TIpv4Validator = Ipv4ValidatorImpl.TIpv4Validator;
TIpv6Validator = Ipv6ValidatorImpl.TIpv6Validator;

TJsonValidator = JsonValidatorImpl.TJsonValidator;

TFileValidator = FileValidatorImpl.TFileValidator;
TDirectoryValidator = DirectoryValidatorImpl.TDirectoryValidator;

TCompareStrValidator = CompareStrValidatorImpl.TCompareStrValidator;
TEqualStrValidator = EqualStrValidatorImpl.TEqualStrValidator;
TCaseInsensitiveEqualStrValidator = CaseInsensitiveEqualStrValidatorImpl.TCaseInsensitiveEqualStrValidator;

TStartWithValidator = StartWithValidatorImpl.TStartWithValidator;
TEndWithValidator = EndWithValidatorImpl.TEndWithValidator;

TLatitudeValidator = LatitudeValidatorImpl.TLatitudeValidator;
TLongitudeValidator = LongitudeValidatorImpl.TLongitudeValidator;

// password-related validation
TAtLeastOneAlphaValidator = AtLeastOneAlphaValidatorImpl.TAtLeastOneAlphaValidator;
TAtLeastOneLowerAlphaValidator = AtLeastOneLowerAlphaValidatorImpl.TAtLeastOneLowerAlphaValidator;
TAtLeastOneUpperAlphaValidator = AtLeastOneUpperAlphaValidatorImpl.TAtLeastOneUpperAlphaValidator;
TAtLeastOneDigitValidator = AtLeastOneDigitValidatorImpl.TAtLeastOneDigitValidator;
TAtLeastOneSymbolValidator = AtLeastOneSymbolValidatorImpl.TAtLeastOneSymbolValidator;
TMixedCapsValidator = MixedCapsValidatorImpl.TMixedCapsValidator;
