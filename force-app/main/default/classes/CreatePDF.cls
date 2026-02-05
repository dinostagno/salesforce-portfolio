public class CreatePDF {

    public static void getPDF(Id recordId) {
        // Ejemplo: obtener datos desde un objeto (Account)
        Account acc = [
            SELECT Id, Name, Industry, Phone
            FROM Account
            WHERE Id = :recordId
            LIMIT 1
        ];

        // Construcción del HTML de forma auxiliar y dinámica
        String htmlContent = buildHtmlContent(acc);

        // Generación del PDF
        Blob pdfBlob = Blob.toPdf(htmlContent);

        // Creación del archivo en Salesforce
        ContentVersion cv = new ContentVersion();
        cv.Title = 'DemoPDF_' + acc.Name + '.pdf';
        cv.PathOnClient = 'DemoPDF_' + acc.Name + '.pdf';
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        cv.FirstPublishLocationId = acc.Id; // Asociado al registro, sin hardcodear Id

        insert cv;
    }

    // Método auxiliar para construir el HTML
    private static String buildHtmlContent(Account acc) {
        String html =
            '<html>' +
                '<body>' +
                    '<h1>Account Information</h1>' +
                    '<p><strong>Name:</strong> ' + acc.Name + '</p>' +
                    '<p><strong>Industry:</strong> ' + acc.Industry + '</p>' +
                    '<p><strong>Phone:</strong> ' + acc.Phone + '</p>' +
                '</body>' +
            '</html>';

        return html;
    }
}