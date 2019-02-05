class node_$example4 {
        $admins = []
        $users = ["Vorname.Nachname"]

        realize(Accounts::Virtual[$admins])
        realize(Accounts::Virtual[$users])
}
