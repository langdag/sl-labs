import React from 'react'
import { createRoot } from 'react-dom/client'
import LoginForm from '../components/LoginForm'

const init = () => {
    const mountNode = document.getElementById('login-form-root')
    if (mountNode) {
        try {
            const signupPath = mountNode.dataset.signupPath
            const loginPath = mountNode.dataset.loginPath
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

            const root = createRoot(mountNode)
            root.render(
                <LoginForm
                    signupPath={signupPath}
                    loginPath={loginPath}
                    csrfToken={csrfToken}
                />
            )
        } catch (error) {
            console.error('Failed to render React component:', error)
        }
    } else {
        console.log('Mount node #login-form-root not found.')
    }
}

if (document.readyState === 'loading') {
    document.addEventListener('turbo:load', init)
} else {
    init()
    document.addEventListener('turbo:load', init)
}
