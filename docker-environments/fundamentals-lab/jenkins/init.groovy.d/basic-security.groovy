#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

def instance = Jenkins.getInstance()

// Créer un utilisateur admin par défaut
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin123")
instance.setSecurityRealm(hudsonRealm)

// Configurer les autorisations
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// Désactiver les remotes CLI
instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Configurer les agents
instance.getDescriptor("jenkins.security.s2m.AdminWhitelistRule").setMasterKillSwitch(false)

instance.save()