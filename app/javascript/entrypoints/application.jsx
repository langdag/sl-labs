import React from 'react'
import { createRoot } from 'react-dom/client'
import LoginForm from '../components/LoginForm'
import SignupForm from '../components/SignupForm'

const init = () => {
    // Mount Login Form
    const loginNode = document.getElementById('login-form-root')
    if (loginNode) {
        try {
            const signupPath = loginNode.dataset.signupPath
            const loginPath = loginNode.dataset.loginPath
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

            const root = createRoot(loginNode)
            root.render(
                <LoginForm
                    signupPath={signupPath}
                    loginPath={loginPath}
                    csrfToken={csrfToken}
                />
            )
        } catch (error) {
            console.error('Failed to render Login component:', error)
        }
    } else {
        console.log('Mount node #login-form-root not found.')
    }

    // Mount Signup Form
    const signupNode = document.getElementById('signup-form-root')
    if (signupNode) {
        try {
            const signupPath = signupNode.dataset.signupPath
            const loginPath = signupNode.dataset.loginPath
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

            const root = createRoot(signupNode)
            root.render(
                <SignupForm
                    signupPath={signupPath}
                    loginPath={loginPath}
                    csrfToken={csrfToken}
                />
            )
        } catch (error) {
            console.error('Failed to render Signup component:', error)
        }
    } else {
        console.log('Mount node #signup-form-root not found.')
    }
}

if (document.readyState === 'loading') {
    document.addEventListener('turbo:load', init)
} else {
    init()
    document.addEventListener('turbo:load', init)
}
