// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import WalletCore
import SessionUtilitiesKit
import Web3Core
import web3swift

public class WalletUtilities{
    public static var account : EMAccount!
    
    public static func createAccount(){
        if let seed = Identity.fetchHexEncodedSeed() {
            let mnemonic = Mnemonic.encode(entropy: seed)
            let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
            if wallet == nil{
                createAccountWithPrivateKey(seed)
                return
            }
            createAccountWithMnemonic(wallet!)
            
            return
        }
        let seed = Identity.fetchUserPrivateKey()!
        let mnemonic = Mnemonic.encode(entropy: seed)
        let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
        if wallet == nil{
            createAccountWithPrivateKey(seed)
            return
        }
        createAccountWithMnemonic(wallet!)
    }
    
    static func createAccountWithPrivateKey(_ seed : Data){
        if let ks = try? EthereumKeystoreV3(privateKey: seed, password: ""){
            self.account = EMAccount.init(address: ks.addresses?.first?.address ?? "", privateKey: seed.hexString)
        }
    }
    
    static func createAccountWithMnemonic(_ wallet : HDWallet){
        let address = wallet.getAddressForCoin(coin: .ethereum)
        let key = wallet.getKeyForCoin(coin: .ethereum).data.hexString
        self.account = EMAccount.init(address: address, privateKey: key)
    }
    
    public static var address : String{
        return self.account.address
    }
    
    static func signPersonalMessage(message : String) -> String?{
        guard let keystore = try! EthereumKeystoreV3(privateKey: Data(hex: self.account.privateKey),password: "")else{
            return nil
        }
        guard let data = message.data(using: String.Encoding.utf8) else{
            return nil
        }
        guard let result = try? Web3Signer.signPersonalMessage(data, keystore: keystore, account: keystore.addresses![0], password: "") else{
            return nil
        }
        return result.hexEncoded
    }
}
