//
//  AppStep.swift
//  SwiftSampleApp
//

import RxFlow

enum AppStep: Step {
    // MARK: - Splash
    case splash

    // MARK: - Auth Gate
    case authRequired
    case showRegister
    case loginComplete

    // MARK: - Tab Bar
    case tabBarIsRequired

    // MARK: - Tab Roots
    case timeline
    case swiper
    case locationMap
    case search
    case profile

    // MARK: - Timeline Actions
    case postDetail(UserPost)
    case createPost

    // MARK: - User Profile
    case userProfile(String)    // target uid
    case followersList(String)  // uid
    case followingList(String)  // uid
    case editProfile

    // MARK: - Chat
    case allChats
    case chatThread(UserModel)  // recipient

    // MARK: - Session
    case logoutComplete
}
