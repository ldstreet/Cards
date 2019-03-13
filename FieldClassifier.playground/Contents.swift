/*:
# Welcome to PlayDocs 🏓

### Cheat Sheet:
*To render markdown:* `Editor -> Show Rendered Markup`

*For raw markup:*  `Editor -> Show Raw Markup`

*Convert to markdown file:*  `playdocs convert FieldClassifier --open`

*Convert to HTML file:*  `playdocs convert FieldClassifier --html --open`
*/
import CreateML
import Foundation
import CoreML

let jsonDecoder = JSONDecoder()

let companiesURL = Bundle.main.url(forResource: "companies", withExtension: "json")!
let companies = try jsonDecoder.decode([String].self, from: try Data(contentsOf: companiesURL))

let namesURL = Bundle.main.url(forResource: "names", withExtension: "json")!
let names = try jsonDecoder.decode([String].self, from: try Data(contentsOf: namesURL))

let titlesURL = Bundle.main.url(forResource: "titles", withExtension: "json")!
let titles = try jsonDecoder.decode([String].self, from: try Data(contentsOf: titlesURL))

enum Classification: String, Codable {
    case company
    case name
    case title
}

struct FieldClassification: Codable {
    let value: String
    let classification: Classification
}

extension Array where Element: Hashable {
    public var unique: [Element] {
        return Array(Set<Element>(self))
    }
}

let companyClassifications =
    zip(
        companies,
        [Classification](repeating: .company, count: companies.count)
    ).map(FieldClassification.init)

let nameClassifications =
    zip(
        names,
        [Classification](repeating: .name, count: names.count)
        ).map(FieldClassification.init)

let titleClassifications =
    zip(
        titles,
        [Classification](repeating: .title, count: titles.count)
        )
        .map(FieldClassification.init)

let classifications = (companyClassifications + nameClassifications + titleClassifications)


let jsonEncoder = JSONEncoder()

let classificationsData = try jsonEncoder.encode(classifications)

let classificationsURL =
    FileManager
        .default
        .homeDirectoryForCurrentUser
        .appendingPathComponent("classifications")
        .appendingPathExtension("json")

try classificationsData.write(to: classificationsURL)

let data = try MLDataTable(contentsOf: classificationsURL)

let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
let fieldClassifier = try MLClassifier(
    trainingData: trainingData,
    targetColumn: "classification",
    featureColumns: ["value"]
)

// Training accuracy as a percentage
let trainingAccuracy = (1.0 - fieldClassifier.trainingMetrics.classificationError) * 100

// Validation accuracy as a percentage
let validationAccuracy = (1.0 - fieldClassifier.validationMetrics.classificationError) * 100

let evaluationMetrics = fieldClassifier.evaluation(on: testingData)

// Evaluation accuracy as a percentage
let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100

let metadata = MLModelMetadata(author: "Luke Street",
                               shortDescription: "A model trained to classify the category of field in a business card",
                               version: "1.0")

try fieldClassifier.write(to: URL(fileURLWithPath: "Users/ldstreet/iOS/Cards/Cards/FieldRecognizer.mlmodel"),
                              metadata: metadata)
