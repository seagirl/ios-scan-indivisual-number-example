//
//  ViewController.swift
//  IndivisualNumberExample
//
//  Created by seagirl on 2021/03/17.
//

import UIKit
import TRETJapanNFCReader

class ViewController: UIViewController {
	var reader: IndividualNumberReader!

	override func viewDidLoad() {
		super.viewDidLoad()

		self.reader = IndividualNumberReader(delegate: self)
	}

	private func getInfo(cardInfoInputSupportAppPIN: String) {
		let items: [IndividualNumberCardItem] = [.tokenInfo, .individualNumber]
		self.reader.get(items: items, cardInfoInputSupportAppPIN: cardInfoInputSupportAppPIN)
	}

	private func presentResult() {
		let alertController = UIAlertController(title: "マイナンバー読み取り完了", message: "マイナンバーを読み取りました。", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))

		self.present(alertController, animated: true, completion: nil)
	}

	@IBAction func onGetButtonDidTap(sender: UIButton) {
		let alertController = UIAlertController(title: "PINコードの入力", message: "連続3回以上間違えると役所でリセットが必要になるのでご注意ください。", preferredStyle: .alert)
		alertController.addTextField { (textField) in
			textField.isSecureTextEntry = true
			textField.keyboardType = .numberPad
		}
		alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "送信", style: .default, handler: { action in
			guard let textField = alertController.textFields?.first,
				  let cardInfoInputSupportAppPIN = textField.text else { return }
			self.getInfo(cardInfoInputSupportAppPIN: cardInfoInputSupportAppPIN)
		}))
		self.present(alertController, animated: true, completion: nil)
	}

	@IBAction func onLookupReaminingButtonDidTap(sender: UIButton) {
		let pinType: IndividualNumberCardPINType = .cardInfoInputSupport

		self.reader.lookupRemainingPIN(pinType: pinType) { (remaining) in
			var message = "不明"
			if let remaining = remaining {
				message = "\(remaining)回"
			}

			let alertController = UIAlertController(title: "残り回数", message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
	}
}

extension ViewController: IndividualNumberReaderSessionDelegate {
	func individualNumberReaderSession(didRead individualNumberCardData: IndividualNumberCardData) {
		guard let token = individualNumberCardData.token, let individualNumber = individualNumberCardData.individualNumber else { return }

		print("<LOG> token: \(token)")
		print("<LOG> individualNumber: \(individualNumber)")

		DispatchQueue.main.async { [weak self] in
			self?.presentResult()
		}
	}

	func japanNFCReaderSession(didInvalidateWithError error: Error) {
		print("<LOG> [ERROR] \(error.localizedDescription)")
	}
}

