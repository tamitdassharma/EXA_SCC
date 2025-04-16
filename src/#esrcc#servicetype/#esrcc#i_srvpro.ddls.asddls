@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Service Product'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SrvPro
  as select from /esrcc/srvpro
  association        to parent /ESRCC/I_SrvPro_S     as _ServiceProductAll on $projection.SingletonID = _ServiceProductAll.SingletonID
  association        to /ESRCC/I_SERVICETYPE_F4      as _ServiceType       on $projection.Servicetype = _ServiceType.ServiceType
  association        to /ESRCC/I_TRANSACTIONGROUP_F4 as _TransactionGroup  on $projection.Transactiongroup = _TransactionGroup.Transactiongroup
  association [0..1] to /ESRCC/I_OECD                as _OECD              on $projection.OecdTpg = _OECD.OECD
  composition [0..*] of /ESRCC/I_SrvProText          as _ServiceProductText
{
  key serviceproduct        as Serviceproduct,
      servicetype           as Servicetype,
      transactiongroup      as Transactiongroup,
      oecdtpg               as OecdTpg,
      ip_owner              as IpOwner,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _ServiceProductAll,
      _ServiceProductText,
      _ServiceType,
      _TransactionGroup,
      _OECD
}
