Config = {}

Config.MaxAttempts = 3
Config.LockoutTime = 60

Config.StashMaxWeight = 500000 
Config.StashSlots = 50

Config.ChestModel = 'prop_ld_int_safe_01'

function Config:GetChestIdentifier(x, y, z)
    local identifier = string.format("chest_%d_%d_%d", math.floor(x), math.floor(y), math.floor(z))
    return identifier
end


Config.Messages = {
    invalid_code = "Code invalide. Veuillez réessayer.",
    correct_code = "Code correct!",
    incorrect_code = "Code incorrect! Veuillez réessayer.",
    lockout = "Vous avez fait trop d'erreurs. Veuillez attendre %d secondes avant de réessayer.",
    chest_created = "Votre coffre a été créé avec succès.",
    chest_deleted = "Coffre supprimé ! Il a été retiré du jeu.",
    no_permissions = "Vous n'avez pas les permissions nécessaires.",
}

Config.AdminGroup = "admin"

Config.InteractionDistance = 2.5
