class node_$example {
        $admins = ["Vorname.Nachname", "weitererVorname.Nachname"]
        $users = ["andererVorname.Nachname"]

        realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])
        realize(Accounts::Virtual[$users])
}
