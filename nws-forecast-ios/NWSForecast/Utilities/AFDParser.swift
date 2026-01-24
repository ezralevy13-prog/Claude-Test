//
//  AFDParser.swift
//  NWSForecast
//
//  Parses and cleans NWS AFD text
//

import Foundation

struct AFDParser {
    static func parse(_ rawText: String) -> [AFDSection] {
        var sections: [AFDSection] = []
        let cleanedText = cleanText(rawText)

        // Common section headers in AFDs
        let sectionPatterns = [
            "SYNOPSIS",
            "NEAR TERM",
            "SHORT TERM",
            "LONG TERM",
            "AVIATION",
            "MARINE",
            "FIRE WEATHER",
            "HYDROLOGY",
            "PRELIMINARY POINT TEMPS/POPS",
            "DISCUSSION",
            "UPDATE"
        ]

        let lines = cleanedText.components(separatedBy: .newlines)
        var currentSection: String?
        var currentContent: [String] = []

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Check if this line is a section header
            if let matchedSection = sectionPatterns.first(where: { pattern in
                trimmedLine.uppercased().hasPrefix(pattern) ||
                trimmedLine.uppercased().hasPrefix(".\(pattern)")
            }) {
                // Save previous section if exists
                if let section = currentSection, !currentContent.isEmpty {
                    let content = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !content.isEmpty {
                        sections.append(AFDSection(
                            title: formatSectionTitle(section),
                            content: formatContent(content)
                        ))
                    }
                }

                // Start new section
                currentSection = matchedSection
                currentContent = []
            } else if currentSection != nil {
                // Add to current section content
                if !trimmedLine.isEmpty {
                    currentContent.append(trimmedLine)
                }
            }
        }

        // Add the last section
        if let section = currentSection, !currentContent.isEmpty {
            let content = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                sections.append(AFDSection(
                    title: formatSectionTitle(section),
                    content: formatContent(content)
                ))
            }
        }

        // If no sections were found, create a single "Discussion" section with all content
        if sections.isEmpty {
            let content = lines
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                .joined(separator: "\n")
            if !content.isEmpty {
                sections.append(AFDSection(
                    title: "Discussion",
                    content: formatContent(content)
                ))
            }
        }

        return sections
    }

    private static func cleanText(_ text: String) -> String {
        var cleaned = text

        // Remove common header patterns
        let headerPatterns = [
            "^\\d{3,4}\\s*$",  // Product codes
            "^[A-Z]{4}\\d{2}\\s+[A-Z]{4}\\s+\\d{6}.*$",  // Timestamp lines
            "^Area Forecast Discussion.*$",
            "^National Weather Service.*$",
            "^\\${2,}",  // Dollar signs
            "^={2,}",    // Equal signs
            "^-{2,}",    // Dashes
        ]

        for pattern in headerPatterns {
            cleaned = cleaned.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .anchored],
                range: nil
            )
        }

        return cleaned
    }

    private static func formatSectionTitle(_ title: String) -> String {
        // Convert "NEAR TERM" to "Near Term"
        return title
            .split(separator: " ")
            .map { word in
                let lowercased = word.lowercased()
                return lowercased.prefix(1).uppercased() + lowercased.dropFirst()
            }
            .joined(separator: " ")
    }

    private static func formatContent(_ content: String) -> String {
        var formatted = content

        // Remove excessive whitespace
        formatted = formatted.replacingOccurrences(
            of: "[ \\t]+",
            with: " ",
            options: .regularExpression
        )

        // Remove multiple consecutive newlines
        formatted = formatted.replacingOccurrences(
            of: "\n{3,}",
            with: "\n\n",
            options: .regularExpression
        )

        // Remove forecaster initials and timestamps at the end
        formatted = formatted.replacingOccurrences(
            of: "\\${2,}.*$",
            with: "",
            options: .regularExpression
        )

        // Convert some common ALL CAPS words to sentence case intelligently
        // Keep acronyms (2-4 letters) in caps, convert longer words
        let words = formatted.components(separatedBy: .whitespaces)
        let processedWords = words.map { word -> String in
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters)

            // Keep short words (likely acronyms) in caps
            if cleaned.count <= 4 && cleaned == cleaned.uppercased() {
                return word
            }

            // Convert longer all-caps words to sentence case
            if cleaned.count > 4 && cleaned == cleaned.uppercased() && cleaned.rangeOfCharacter(from: .lowercaseLetters) == nil {
                let lowercased = word.lowercased()
                if let firstChar = lowercased.first {
                    return String(firstChar).uppercased() + lowercased.dropFirst()
                }
            }

            return word
        }

        formatted = processedWords.joined(separator: " ")

        return formatted.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
