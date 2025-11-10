@EndUserText.label: 'Service Product Benefits and Activities'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/C_SRVPROTEXT_BENEFITS 
provider contract transactional_query
as projection on /ESRCC/I_SRVPROTEXT_BENEFITS
{
    key Spras,
    key Serviceproduct,
    Description,
    Activities,
    Benefit,
    LocalLastChangedAt,
    /* Associations */
    _LanguageText
}
