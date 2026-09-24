import SwiftUI

struct GroupsView: View {
    @Environment(GroupStore.self) private var store
    @State private var creating = false
    @State private var confirmingRemoveAll = false

    var body: some View {
        List {
            ForEach(store.groups) { group in
                NavigationLink(value: group) {
                    VStack(alignment: .leading) {
                        Text(verbatim: group.name)
                        Text("\(group.lessonIDs.count) lessons")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                let ids = offsets.map { store.groups[$0].id }
                for id in ids { try? store.remove(id) }
            }
        }
        .overlay {
            if store.groups.isEmpty {
                ContentUnavailableView {
                    Label("Your groups", systemImage: "folder")
                } description: {
                    Text("Yet there is not one group. But you can create new one by clicking on button Add on toolbar.")
                } actions: {
                    Button("Create new list of lessons") { creating = true }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Your groups")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    creating = true
                } label: {
                    Label("New group", systemImage: "plus")
                }
            }
            if !store.groups.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        confirmingRemoveAll = true
                    } label: {
                        Label("Remove all groups", systemImage: "trash")
                    }
                }
            }
        }
        .confirmationDialog("Removing your groups", isPresented: $confirmingRemoveAll, titleVisibility: .visible) {
            Button("Remove all groups", role: .destructive) { try? store.removeAll() }
        } message: {
            Text("This action will remove all your groups. Sure to continue ?")
        }
        .sheet(isPresented: $creating) {
            GroupEditView(group: nil)
        }
    }
}

struct GroupView: View {
    @Environment(Library.self) private var library
    @Environment(GroupStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let groupID: UUID
    @State private var editing = false
    @State private var reminding = false
    @State private var confirmingRemove = false

    var body: some View {
        if let group = store.group(groupID) {
            LessonList(lessons: library.lessons(group.lessonIDs))
                .navigationTitle(group.name)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            reminding = true
                        } label: {
                            Label("Setup reminder", systemImage: "alarm")
                        }
                        Menu {
                            Button {
                                editing = true
                            } label: {
                                Label("Edit group", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                confirmingRemove = true
                            } label: {
                                Label("Remove group", systemImage: "trash")
                            }
                        } label: {
                            Label("More", systemImage: "ellipsis.circle")
                        }
                    }
                }
                .sheet(isPresented: $editing) {
                    GroupEditView(group: group)
                }
                .sheet(isPresented: $reminding) {
                    ReminderSheet(title: String(localized: "There are the group of lessons to study the \"Mobile grammar\""),
                                  message: group.name)
                }
                .confirmationDialog("Removing this group", isPresented: $confirmingRemove, titleVisibility: .visible) {
                    Button("Remove group", role: .destructive) {
                        try? store.remove(groupID)
                        dismiss()
                    }
                } message: {
                    Text("This action will remove selected group. Sure to continue ?")
                }
        } else {
            ContentUnavailableView("It seems that there is no such group.", systemImage: "folder")
        }
    }
}

/// Creates a group (group nil) or edits one: a name and lessons chosen from the list.
struct GroupEditView: View {
    @Environment(Library.self) private var library
    @Environment(GroupStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let group: LessonGroup?
    @State private var name: String
    @State private var selected: Set<Int>
    @State private var query = ""
    @State private var error: GroupValidationError?
    @State private var saveFailed = false

    init(group: LessonGroup?) {
        self.group = group
        _name = State(initialValue: group?.name ?? "")
        _selected = State(initialValue: Set(group?.lessonIDs ?? []))
    }

    var body: some View {
        let title: LocalizedStringKey = group == nil ? "New group" : "Edit group"
        let saveTitle: LocalizedStringKey = group == nil ? "Save group" : "Update group"
        NavigationStack {
            List {
                Section {
                    TextField("Enter name of group …", text: $name)
                        .accessibilityIdentifier("groupName")
                } footer: {
                    if error == .emptyName {
                        Text("Please, name this group somehow …").foregroundStyle(.red)
                    } else if error == .nameTooLong {
                        Text("Sorry, it's too long group name. Please, keep within 50 characters").foregroundStyle(.red)
                    }
                }
                Section {
                    // a field in the form, not .searchable: an active search bar hides the Save button
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Enter article name …", text: $query)
                            .autocorrectionDisabled()
                            .accessibilityIdentifier("lessonFilter")
                    }
                    ForEach(Library.search(library.lessons, for: query)) { lesson in
                        Button {
                            toggle(lesson.id)
                        } label: {
                            HStack {
                                Text(verbatim: lesson.title).foregroundStyle(.primary)
                                Spacer()
                                if selected.contains(lesson.id) {
                                    Image(systemName: "checkmark").foregroundStyle(.tint)
                                }
                            }
                        }
                        .accessibilityAddTraits(selected.contains(lesson.id) ? .isSelected : [])
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Check lessons which you want to add to the new group")
                            .foregroundStyle(error == .noLessons ? Color.red : Color.secondary)
                        Text("Selected: \(selected.count)")
                    }
                    .textCase(nil)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveTitle) { save() }
                }
            }
            .alert("Couldn't save the group.", isPresented: $saveFailed) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func toggle(_ id: Int) {
        if selected.contains(id) {
            selected.remove(id)
        } else {
            selected.insert(id)
            if error == .noLessons { error = nil }
        }
    }

    private func save() {
        do {
            try store.save(id: group?.id, name: name, lessonIDs: selected)
            dismiss()
        } catch let validation as GroupValidationError {
            error = validation
        } catch {
            saveFailed = true
        }
    }
}
