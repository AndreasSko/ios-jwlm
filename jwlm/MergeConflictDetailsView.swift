//
//  MergeConflictView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 28.10.20.
//

import SwiftUI
import Gomobile

struct MergeConflictDetailsView: View {
    var conflict: MergeConflict?
    var side: MergeSide

    var body: some View {
        VStack(alignment: .leading) {
            switch selectConflict().model {
            case .bookmark(let bookmark):
                BookmarkDetail(bookmark: bookmark)
                    .frame(maxWidth: .infinity)
                    .padding()
            case .userMarkBlockRange(let umbr):
                UserMarkBlockRangeDetail(umbr: umbr)
                    .frame(maxWidth: .infinity)
                    .padding()
            case .note(let note):
                NoteDetail(note: note)
                    .frame(maxWidth: .infinity)
                    .padding()
            default:
                Text("Error! Can not generate preview")
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .shadow(color: Color.gray.opacity(0.2), radius: 20)
        .contentShape(Rectangle())
    }

    func selectConflict() -> ModelRelatedTuple {
        if side == .leftSide {
            return conflict!.left!
        }
        return conflict!.right!
    }
}

struct MergeConflictView_Previews: PreviewProvider {
    static var previews: some View {
        MergeConflictDetailsView(conflict: nil, side: .leftSide)
    }
}

struct BookmarkDetail: View {
    var bookmark: Bookmark

    var body: some View {
            HStack {
            VStack(alignment: .leading) {
                KeyValue(key: "Title:", value: bookmark.title)

                if bookmark.snippet.valid && bookmark.snippet.string != "" {
                    KeyValue(key: "Snippet:", value: bookmark.snippet.string)
                }

            if bookmark.blockIdentifier.valid {
                    KeyValue(key: "Paragraph:", value: String(bookmark.blockIdentifier.int32))
                }
            }
            Spacer()
        }
    }
}

struct NoteDetail: View {
    var note: Note

    var body: some View {
                HStack {
            VStack(alignment: .leading) {
                if note.title.valid {
                    KeyValue(key: "Title:", value: note.title.string)
                }

                if note.content.valid {
                    KeyValue(key: "Content:", value: note.content.string)
            }

                KeyValue(key: "Last Modified:", value: note.lastModified)
                }
            Spacer()
            }
            }
        }

struct UserMarkBlockRangeDetail: View {
    var umbr: UserMarkBlockRange

    var body: some View {
        VStack(alignment: .custom) {
            HStack {
                Text("Color:").bold()
                Circle()
                    .fill(translateColor(umbr.userMark.colorIndex))
                    .frame(width: 20, height: 20)
                    .alignmentGuide(.custom) { $0[.leading] }
            }
            .padding(.bottom, 2.0)

            ForEach(umbr.blockRanges, id: \.blockRangeId) { blockRange in
                HStack {
                    Text("Paragraph:").bold()
                    Text("\(blockRange.identifier)").alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)

                if blockRange.startToken.valid {
                    HStack {
                        Text("Start token:").bold()
                        Text("\(blockRange.startToken.int32)").alignmentGuide(.custom) { $0[.leading] }
                    }
                    .padding(.bottom, 0.5)
                }

                if blockRange.endToken.valid {
                    HStack {
                        Text("End token:").bold()
                        Text("\(blockRange.endToken.int32)").alignmentGuide(.custom) { $0[.leading] }
                    }
                    .padding(.bottom, 2.0)
                }
            }
        }
    }

    func translateColor(_ index: Int) -> Color {
        var color: Color
        switch index {
        case 1:
            color = Color(red: 1.00, green: 0.93, blue: 0.23)
        case 2:
            color = Color(red: 0.62, green: 0.98, blue: 0.32)
        case 3:
            color = Color(red: 0.16, green: 0.71, blue: 0.96)
        case 4:
            color = Color(red: 1.00, green: 0.63, blue: 0.78)
        case 5:
            color = Color(red: 1.00, green: 0.73, blue: 0.46)
        case 6:
            color = Color(red: 0.68, green: 0.52, blue: 1.00)

        default:
            color = Color(red: 0, green: 0, blue: 0)
        }

        return color
    }
}

struct KeyValue: View {
    var key: String
    var value: String

    var body: some View {
        Text(NSLocalizedString(key, comment: "String")).bold()
        Text(value)
            .padding(.bottom, 0.5)
    }
}

// https://www.objc.io/blog/2020/03/05/swiftui-alignment-guides/
struct CustomAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        return context[.leading]
    }
}
extension HorizontalAlignment {
    static let custom: HorizontalAlignment = HorizontalAlignment(CustomAlignment.self)
}
