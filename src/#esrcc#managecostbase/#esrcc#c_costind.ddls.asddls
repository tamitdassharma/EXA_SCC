@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Change Cost Indicator'
define abstract entity /ESRCC/C_COSTIND  
{   
    @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTIND', element: 'costind' }}]    
    @UI.textArrangement: #TEXT_ONLY
    costind : /esrcc/costind_de;
    
}
