class node_$example2 {
        $admins = []
        $users = ["Vorname.Nachname"]

        realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])
        realize(Accounts::Virtual[$users])
}
