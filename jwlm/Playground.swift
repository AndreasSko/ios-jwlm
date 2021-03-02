//
//  Playground.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 10.11.20.
//

import SwiftUI

struct Playground: View {
    var body: some View {
        VStack {
            HStack {
                        VStack {
                            Text("@twostraws")
                            Image("paul-hudson")
                                .resizable()
                                .frame(width: 64, height: 64)
                        }

                        VStack {
                            Text("Full name:")
                            Text("PAUL HUDSON")
                                .font(.largeTitle)
                        }
                    }

            Text("A conflict happened while merging")
                + Text(" markings.").bold()
            HStack {
                VStack(alignment: .trailing) {
                    Text("Publication:")
                        .bold()
                    Text("Book number:")
                        .bold()
                    Text("Chapter number:")
                        .bold()
                }
                VStack(alignment: .leading) {
                    Text("nwtsty")
                    Text("12")
                    Text("3")
                }
                Spacer()
            }
            .padding()
            .border(Color.black)

            Menu {
                Button(action: {

                }, label: {
                    Text("Title")
                    Text("A very very long answer")
                })
            } label: {
                Image(systemName: "bookmark")
            }

            Spacer()

            VStack(alignment: .custom) {
                let width = UIScreen.main.bounds.width - 80
                HStack {
                    Text("Color:").font(Font.body.bold())
                    Circle()
                        .fill(Color(red: 1, green: 0.918, blue: 0.231))
                        .frame(width: 20, height: 20)
                        .alignmentGuide(.custom) { $0[.leading] }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: width)

                HStack {
                    Text("Publication:").font(Font.body.bold())
                    Text("Offenbarung 21:4").alignmentGuide(.custom) { $0[.leading] }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: width)

                HStack(alignment: .top) {
                    Text("Snippet:").font(Font.body.bold())
                    Text("Und er wird").alignmentGuide(.custom) { $0[.leading] }
                    Spacer()
                }
                .padding(.bottom, 1.0)
                .frame(maxWidth: width)

                HStack {
                    Text("Paragraph:").font(Font.body.bold())
                    Text("4").alignmentGuide(.custom) { $0[.leading] }
                    Spacer()
                }
                .frame(maxWidth: width)
                .padding(.bottom, 20.0)
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
            )
            .padding([.top, .horizontal])
            .shadow(radius: 20)

            Spacer()
        }
    }
}

struct Playground_Previews: PreviewProvider {
    static var previews: some View {
        Playground()
    }
}
