@EndUserText.label: 'Invoice Options'
define abstract entity /ESRCC/C_INVOICEOPTIONS
{
    @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_INVOICEOPTIONS', element: 'InvoiceOption' } }]
    @EndUserText.label: 'Invoice Creation'
    @UI.textArrangement: #TEXT_ONLY
    @Consumption.filter.mandatory: true
    key InvoiceOption : /esrcc/invoiceoptions;    
}
