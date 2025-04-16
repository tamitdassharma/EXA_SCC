@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Assign Cost Data Set'
define abstract entity /ESRCC/C_COSTDATASET  
{   
    @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTDATASET', element: 'costdataset' }}]    
    @EndUserText.label: 'Cost Data Set'
    @UI.textArrangement: #TEXT_ONLY
    costdataset : /esrcc/costdataset_de;
    
}
