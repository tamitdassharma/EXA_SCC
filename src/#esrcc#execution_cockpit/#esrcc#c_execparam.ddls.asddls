@EndUserText.label: 'Execution Cockpit Parameters'
define abstract entity /ESRCC/C_EXECPARAM
{
    @UI.selectionField     : [{ position: 15 }]
    @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTDATASET', element: 'costdataset' } }]
    @Consumption.filter.selectionType: #SINGLE   
    @UI.textArrangement    : #TEXT_ONLY
    key fplv : /esrcc/costdataset_de;
    
}
