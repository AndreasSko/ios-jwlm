//
//  MergeConflictOverview.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 10.11.20.
//

import SwiftUI

struct MergeConflictOverview: View {
    var mrt: ModelRelatedTuple?

    var body: some View {
        VStack {
            let related = mrt?.related
            switch mrt?.model {
            case .bookmark(let bookmark):
                BookmarkOverview(bookmark: bookmark, related: related)
            case .userMarkBlockRange(let umbr):
                UserMarkBlockRangeOverview(umbr: umbr, related: related)
            case .note(let note):
                NoteOverview(note: note, related: related)
            default:
                Text("Error! Can not generate preview")
            }
        }
    }
}

struct BookmarkOverview: View {
    var bookmark: Bookmark
    var related: Related?

    var body: some View {
        VStack(alignment: .custom) {
            if related?.publicationLocation?.keySymbol.valid ?? false {
                HStack {
                    Text("Publication:").bold()
                    Text(related?.publicationLocation?.keySymbol.string ?? "")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            HStack(alignment: .top) {
                Text("Slot:").bold()
                Text("\(bookmark.slot)").alignmentGuide(.custom) { $0[.leading] }
            }
        }
    }
}

struct NoteOverview: View {
    var note: Note
    var related: Related?

    var body: some View {
        VStack(alignment: .custom) {
            if related?.location?.title.valid ?? false {
                HStack {
                    Text("Location Title:").bold()
                    Text("\(related?.location?.title.string ?? "")")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
            }

            if related?.location?.keySymbol.valid ?? false {
                HStack {
                    Text("Publication:").bold()
                    Text("\(related?.location?.keySymbol.string ?? "")")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.bookNumber.valid ?? false {
                HStack {
                    Text("Book number:").bold()
                    Text("\(related?.location?.bookNumber.int32 ?? -1)")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.chapterNumber.valid ?? false {
                HStack {
                    Text("Chapter number:").bold()
                    Text("\(related?.location?.chapterNumber.int32 ?? -1)")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.documentId.valid ?? false {
                HStack {
                    Text("Document ID:").bold()
                    Text(String(related?.location?.documentId.int32 ?? -1))
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.track.valid ?? false {
                HStack {
                    Text("Track:").bold()
                    Text("\(related?.location?.track.int32 ?? -1)")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }
        }
    }
}

struct UserMarkBlockRangeOverview: View {
    var umbr: UserMarkBlockRange
    var related: Related?

    var body: some View {
        VStack(alignment: .custom) {
            if related?.location?.title.valid ?? false {
                HStack {
                    Text("Title:").bold()
                    Text("\(related?.location?.title.string ?? "")")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.keySymbol.valid ?? false {
                HStack {
                    Text("Publication:").bold()
                    Text("\(related?.location?.keySymbol.string ?? "")")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.bookNumber.valid ?? false {
                HStack {
                    Text("Book number:").bold()
                    Text("\(related?.location?.bookNumber.int32 ?? -1)")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.chapterNumber.valid ?? false {
                HStack {
                    Text("Chapter number:").bold()
                    Text("\(related?.location?.chapterNumber.int32 ?? -1)")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.documentId.valid ?? false {
                HStack {
                    Text("Document ID:").bold()
                    Text(String(related?.location?.documentId.int32 ?? -1))
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }

            if related?.location?.track.valid ?? false {
                HStack {
                    Text("Track:").bold()
                    Text("\(related?.location?.track.int32 ?? -1)")
                        .alignmentGuide(.custom) { $0[.leading] }
                }
                .padding(.bottom, 0.5)
            }
        }
    }
}

struct MergeConflictOverview_Previews: PreviewProvider {
    static var previews: some View {
        MergeConflictOverview(mrt: nil)
    }
}