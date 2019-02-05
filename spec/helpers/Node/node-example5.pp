class node_$example4 {
        $admins = []
        $users = ["Vorname.Nachname"]

        realize(Accounts::Sudoroot[$admins])
        realize(Accounts::Virtual[$users])
}
