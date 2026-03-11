import SwiftUI

struct DrinkTypePicker: View {
    let drinkTypes: [DrinkType]
    @Binding var selectedType: DrinkType?

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(drinkTypes, id: \.id) { type in
                Button(action: {
                    selectedType = type
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: type.icon)
                            .font(.system(size: 32))
                            .foregroundColor(selectedType?.id == type.id ? .blue : .primary)

                        Text(type.name)
                            .font(.system(size: 14))
                            .foregroundColor(selectedType?.id == type.id ? .blue : .secondary)
                    }
                    .frame(width: 90, height: 90)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedType?.id == type.id ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedType?.id == type.id ? Color.blue.opacity(0.1) : Color.clear)
                            )
                    )
                }
            }
        }
    }
}
