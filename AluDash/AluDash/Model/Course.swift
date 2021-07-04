//
//  Course.swift
//  AluDash
//
//  Created by Rafael Escaleira on 04/07/21.
//

import Foundation

struct Course: Codable {
    static let url: String = "https://www.alura.com.br/api/curso-"
    var slug: String?
    var nome: String?
    var metadescription: String?
    var quantidade_avaliacoes: Int?
    var carga_horaria: Int?
    var quantidade_atividades: Int?
    var data_criacao: String?
    var data_atualizacao: String?
    var publico_alvo: String?
    var ementa: [Grade]?

    struct Grade: Codable {
        var capitulo: String?
        var secoes: [String]?
    }
}
