@EndUserText.label: 'Other Information - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LeOthers
  as projection on /ESRCC/I_LeOthers
{
      @ObjectModel.text.element: ['LegalEntityDescription']
  key LegalEntity,
      @ObjectModel.text.element: ['RoleDescription']
  key Role,
      @ObjectModel.text.element: ['SysidDescription']
  key Sysid,
      @ObjectModel.text.element: ['CcodeDescription']
  key CompanyCode,
      @ObjectModel.text.element: ['CostObjectDescription']
  key Costobject,
      @ObjectModel.text.element: ['BusinessDivisionDescription']
  key BusinessDivision,
      @ObjectModel.text.element: ['TransactionGroupDescription']
  key TransactionGroup,
      Account,
      BusinessPartnerNumber,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _CompanyCodeText.LegalentityDescription,
      @Semantics.text: true
      _CompanyCodeText.ccodedescription as CcodeDescription,
      @Semantics.text: true
      _Role.text                        as RoleDescription,
      @Semantics.text: true
      _SystemText.Description           as SysidDescription,
      @Semantics.text: true
      _CostObject.text                  as CostObjectDescription,
      @Semantics.text: true
      _BusinessDivision.Description     as BusinessDivisionDescription,
      @Semantics.text: true
      _TransactionGroup.Description     as TransactionGroupDescription,
      _OtherInformationAll : redirected to parent /ESRCC/C_LeOthers_S

}
