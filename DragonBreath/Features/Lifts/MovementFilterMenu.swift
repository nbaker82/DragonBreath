import SwiftUI
import SwiftData

struct MovementFilterMenu: View {
    @Bindable var vm: LiftLogViewModel
    let movements: [Movement]

    var body: some View {
        Menu {
            Button("All Movements") { vm.selectedMovement = nil }
            Divider()
            ForEach(movements) { movement in
                Button(movement.name) { vm.selectedMovement = movement }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundStyle(vm.selectedMovement != nil ? Color.brand : .primary)
        }
    }
}
