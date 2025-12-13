//
//  ExportView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 09/04/25.
//


import SwiftUI
import SQLite3
import UniformTypeIdentifiers

struct ExportView: View {
    @State private var exportMessage = ""
    @State private var csvFileURL: URL?
    @State private var isSharePresented = false
    @State private var rowCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Button("Export to CSV") {
                exportToCSV()
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("🖨 Export to PDF") {
                exportToPDF()
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)

            if csvFileURL != nil && rowCount > 0 {
                Button("📤 Share Exported File") {
                    isSharePresented = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            if !exportMessage.isEmpty {
                Text(exportMessage)
                    .font(.footnote)
                    .foregroundColor(rowCount == 0 ? .red : .gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .sheet(isPresented: $isSharePresented) {
            if let url = csvFileURL {
                ShareSheet(activityItems: [url])
            }
        }
        .navigationTitle("Export Students")
        .padding()
    }

    // MARK: - CSV Export
    func exportToCSV() {
        var csv = ""
        rowCount = 0

        csv += "🧑 Students\n"
        csv += "Username,Name,Email,Mobile,Address,College,StudentID\n"
        let studentRows = fetchTableData(from: "SELECT * FROM Students") { stmt in
            let username = String(cString: sqlite3_column_text(stmt, 0))
            let name = String(cString: sqlite3_column_text(stmt, 2))
            let email = String(cString: sqlite3_column_text(stmt, 3))
            let mobile = String(cString: sqlite3_column_text(stmt, 4))
            let address = String(cString: sqlite3_column_text(stmt, 5))
            let college = String(cString: sqlite3_column_text(stmt, 6))
            let studentID = String(cString: sqlite3_column_text(stmt, 7))
            return "\(username),\(name),\(email),\(mobile),\(address),\(college),\(studentID)"
        }
        csv += studentRows.text
        rowCount += studentRows.count
        csv += "\n"

        csv += "📝 Notes\nID,Title,Content\n"
        let noteRows = fetchTableData(from: "SELECT * FROM Notes") { stmt in
            let id = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let content = String(cString: sqlite3_column_text(stmt, 2))
            return "\(id),\(title),\(content)"
        }
        csv += noteRows.text
        rowCount += noteRows.count
        csv += "\n"

        csv += "✅ Tasks\nID,Task,Done\n"
        let taskRows = fetchTableData(from: "SELECT * FROM Tasks") { stmt in
            let id = sqlite3_column_int(stmt, 0)
            let task = String(cString: sqlite3_column_text(stmt, 1))
            let done = sqlite3_column_int(stmt, 2)
            return "\(id),\(task),\(done == 1 ? "Yes" : "No")"
        }
        csv += taskRows.text
        rowCount += taskRows.count
        csv += "\n"

        csv += "📅 Class Schedule\nID,Subject,Time\n"
        let scheduleRows = fetchTableData(from: "SELECT * FROM Schedule") { stmt in
            let id = sqlite3_column_int(stmt, 0)
            let subject = String(cString: sqlite3_column_text(stmt, 1))
            let time = String(cString: sqlite3_column_text(stmt, 2))
            return "\(id),\(subject),\(time)"
        }
        csv += scheduleRows.text
        rowCount += scheduleRows.count

        if rowCount == 0 {
            exportMessage = "❌ Nothing to export!"
            csvFileURL = nil
            return
        }

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("CampusBuddyExport.csv")
        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            csvFileURL = fileURL
            exportMessage = "✅ CSV created with \(rowCount) rows of data."
        } catch {
            exportMessage = "❌ Failed to save CSV file."
            csvFileURL = nil
        }
    }

    // MARK: - PDF Export
    func exportToPDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "Campus Buddy",
            kCGPDFContextAuthor: "Campus Buddy App"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 595.2
        let pageHeight = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("CampusBuddyExport.pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        do {
            try renderer.writePDF(to: fileURL) { context in
                context.beginPage()
                let title = "Campus Buddy Data Export"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ]
                title.draw(at: CGPoint(x: 72, y: 72), withAttributes: attributes)

                var y: CGFloat = 110
                let font = UIFont.systemFont(ofSize: 12)
                let lineHeight: CGFloat = 16

                func drawSection(title: String, query: String, rowBuilder: (OpaquePointer) -> String) {
                    title.draw(at: CGPoint(x: 72, y: y), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
                    y += 20

                    let result = fetchTableData(from: query, rowBuilder: rowBuilder)
                    for line in result.text.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
                        line.draw(at: CGPoint(x: 72, y: y), withAttributes: [.font: font])
                        y += lineHeight

                        if y > pageHeight - 50 {
                            context.beginPage()
                            y = 72
                        }
                    }
                    y += 20
                }

                drawSection(title: "🧑 Students", query: "SELECT * FROM Students") { stmt in
                    let username = String(cString: sqlite3_column_text(stmt, 0))
                    let name = String(cString: sqlite3_column_text(stmt, 2))
                    let email = String(cString: sqlite3_column_text(stmt, 3))
                    let mobile = String(cString: sqlite3_column_text(stmt, 4))
                    let address = String(cString: sqlite3_column_text(stmt, 5))
                    let college = String(cString: sqlite3_column_text(stmt, 6))
                    let studentID = String(cString: sqlite3_column_text(stmt, 7))
                    return "\(username), \(name), \(email), \(mobile), \(address), \(college), \(studentID)"
                }

                drawSection(title: "📝 Notes", query: "SELECT * FROM Notes") { stmt in
                    let id = sqlite3_column_int(stmt, 0)
                    let title = String(cString: sqlite3_column_text(stmt, 1))
                    let content = String(cString: sqlite3_column_text(stmt, 2))
                    return "\(id). \(title): \(content)"
                }

                drawSection(title: "✅ Tasks", query: "SELECT * FROM Tasks") { stmt in
                    let id = sqlite3_column_int(stmt, 0)
                    let task = String(cString: sqlite3_column_text(stmt, 1))
                    let done = sqlite3_column_int(stmt, 2)
                    return "\(id). \(task) [\(done == 1 ? "Done" : "Pending")]"
                }

                drawSection(title: "📅 Class Schedule", query: "SELECT * FROM Schedule") { stmt in
                    let id = sqlite3_column_int(stmt, 0)
                    let subject = String(cString: sqlite3_column_text(stmt, 1))
                    let time = String(cString: sqlite3_column_text(stmt, 2))
                    return "\(id). \(subject) at \(time)"
                }
            }

            self.csvFileURL = fileURL
            self.isSharePresented = true
            self.exportMessage = "✅ PDF export complete!"
        } catch {
            exportMessage = "❌ Failed to generate PDF."
        }
    }

    // MARK: - Reusable Fetch Helper
    func fetchTableData(from query: String, rowBuilder: (OpaquePointer) -> String) -> (text: String, count: Int) {
        var result = ""
        var count = 0
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            if let stmt = stmt {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    result += rowBuilder(stmt) + "\n"
                    count += 1
                }
                sqlite3_finalize(stmt)
            }
        }

        return (result, count)
    }
}
