/*
 * Copyright (c) 2026 Dino Stagno
 *
 * Licensed for internal use within Salesforce applications.
 * This file is provided "as is", without warranties of any kind,
 * either express or implied.
 */

/**
 * @group Document Generation
 * @author Dino Stagno
 * @description
 * CreatePDF is a service class responsible for generating PDF documents
 * dynamically using Apex and the Blob.toPdf() capability.
 *
 * This class provides a reusable and scalable approach to:
 * - Retrieve business data directly from Salesforce objects.
 * - Build HTML content programmatically using well-defined templates.
 * - Generate PDF files without relying on Visualforce rendering.
 * - Persist generated PDFs as ContentVersion records linked to Salesforce data.
 *
 * The class is intentionally focused on PDF generation concerns only.
 * Data preparation, template selection, and orchestration logic
 * can be extended or delegated to higher-level services if needed.
 */

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