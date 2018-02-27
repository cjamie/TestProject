//
//  AppointmentService.swift
//  TestProject
//
//  Created by Patel, Sanjay on 3/31/17.
//  Copyright © 2017 Patel, Sanjay. All rights reserved.
//

import Foundation

protocol AppointmentServiceDelegate: class {
    func appointmentsRetrieved(pastAppointmentArray: [Appointment], futureAppointmentArray: [Appointment])
}

class AppointmentService {
    
    weak var delegate: AppointmentServiceDelegate?
    
    private init() { }
    
    public static func getInstance() -> AppointmentService {
        return instance
    }
    
    private static let instance : AppointmentService = AppointmentService()
    
    func getAppointments() {
        
        var pastAppointments = [Appointment]()
        var futureAppointments = [Appointment]()
        
        pastAppointments.append(Appointment(providerFirstName: "Okan", providerLastName: "Elidemir", providerSpecialty: "Specialty A", providerId: "64893", dateAndTime: Date().addingTimeInterval(-4012324), address: "1600 Rockland Rd, Ste 1302, Wilmington, DE 19803", isAsthmaAppointment: false))
        pastAppointments.append(Appointment(providerFirstName: "Louis", providerLastName: "Guernsey", providerSpecialty: "Specialty B", providerId: "205", dateAndTime: Date().addingTimeInterval(-6431432), address: "1600 Rockland Rd, Ste 1302, Wilmington, DE 19803", isAsthmaAppointment: true))
        pastAppointments.append(Appointment(providerFirstName: "Hudak", providerLastName: "Bonnie", providerSpecialty: "Specialty C", providerId: "2562", dateAndTime: Date().addingTimeInterval(-8125473), address: "1600 Rockland Rd, Ste 1302, Wilmington, DE 19803", isAsthmaAppointment: true))
        
        futureAppointments.append(Appointment(providerFirstName: "Okan", providerLastName: "Elidemir", providerSpecialty: "Specialist A", providerId: "64893", dateAndTime: Date().addingTimeInterval(252635), address: "1600 Rockland Rd, Ste 1302, Wilmington, DE 19803", isAsthmaAppointment: false))
        futureAppointments.append(Appointment(providerFirstName: "Louis", providerLastName: "Guernsey", providerSpecialty: "Specialist B", providerId: "205", dateAndTime: Date().addingTimeInterval(442534), address: "1600 Rockland Rd, Ste 1302, Wilmington, DE 19803", isAsthmaAppointment: false))
        futureAppointments.append(Appointment(providerFirstName: "Hudak", providerLastName: "Bonnie", providerSpecialty: "Specialist C", providerId: "2562", dateAndTime: Date().addingTimeInterval(654323), address: "1600 Rockland Rd, Ste 1302, Wilmington, DE 19803", isAsthmaAppointment: true))
        futureAppointments.append(Appointment(providerFirstName: "Hudak", providerLastName: "Bonnie", providerSpecialty: "Specialist C", providerId: "2562", dateAndTime: Date().addingTimeInterval(754323), address: "1600 Rockland Rd, Ste 1302, Wilmington, DE 19803", isAsthmaAppointment: true))
        
        delegate?.appointmentsRetrieved(pastAppointmentArray: pastAppointments, futureAppointmentArray: futureAppointments)
        
    }
    
}

