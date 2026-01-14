import React, { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Mail, Lock, Eye, EyeOff, Loader2, UserPlus, ShieldCheck, Github } from 'lucide-react'

const SignupForm = ({ signupPath, loginPath, csrfToken }) => {
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [passwordConfirmation, setPasswordConfirmation] = useState('')
    const [showPassword, setShowPassword] = useState(false)
    const [loading, setLoading] = useState(false)
    const [isFocused, setIsFocused] = useState(null)

    const handleSubmit = (e) => {
        // We let the form submit naturally to Rails controller
        setLoading(true)
    }

    const isPasswordMatch = password === passwordConfirmation && password !== ''

    const containerVariants = {
        hidden: { opacity: 0, y: 20 },
        visible: {
            opacity: 1,
            y: 0,
            transition: { duration: 0.6, ease: [0.16, 1, 0.3, 1] }
        }
    }

    return (
        <div className="auth-container">
            <motion.div
                className="auth-card"
                initial="hidden"
                animate="visible"
                variants={containerVariants}
            >
                <div className="auth-header">
                    <motion.div
                        initial={{ scale: 0.8, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        transition={{ delay: 0.2 }}
                        className="brand-icon"
                    >
                        <Github size={40} strokeWidth={1.5} />
                    </motion.div>
                    <h1>Create your account</h1>
                    <p>Join the SL Labs developer community</p>
                </div>

                <form action={signupPath} method="post" className="auth-form" onSubmit={handleSubmit}>
                    <input type="hidden" name="authenticity_token" value={csrfToken} />

                    <div className={`form-group ${isFocused === 'email' ? 'focused' : ''}`}>
                        <label htmlFor="user_email_address">Email address</label>
                        <div className="input-wrapper">
                            <Mail className="input-icon" size={18} />
                            <input
                                type="email"
                                name="user[email_address]"
                                id="user_email_address"
                                required
                                autoFocus
                                placeholder="name@company.com"
                                className="form-input"
                                value={email}
                                onFocus={() => setIsFocused('email')}
                                onBlur={() => setIsFocused(null)}
                                onChange={(e) => setEmail(e.target.value)}
                            />
                        </div>
                    </div>

                    <div className={`form-group ${isFocused === 'password' ? 'focused' : ''}`}>
                        <label htmlFor="user_password">Password</label>
                        <div className="input-wrapper">
                            <Lock className="input-icon" size={18} />
                            <input
                                type={showPassword ? "text" : "password"}
                                name="user[password]"
                                id="user_password"
                                required
                                placeholder="••••••••"
                                className="form-input"
                                value={password}
                                onFocus={() => setIsFocused('password')}
                                onBlur={() => setIsFocused(null)}
                                onChange={(e) => setPassword(e.target.value)}
                            />
                            <button
                                type="button"
                                className="password-toggle"
                                onClick={() => setShowPassword(!showPassword)}
                                aria-label="Toggle password visibility"
                            >
                                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                            </button>
                        </div>
                    </div>

                    <div className={`form-group ${isFocused === 'password_confirmation' ? 'focused' : ''}`}>
                        <label htmlFor="user_password_confirmation">Confirm Password</label>
                        <div className="input-wrapper">
                            <ShieldCheck className={`input-icon ${isPasswordMatch ? 'success' : ''}`} size={18} />
                            <input
                                type={showPassword ? "text" : "password"}
                                name="user[password_confirmation]"
                                id="user_password_confirmation"
                                required
                                placeholder="••••••••"
                                className="form-input"
                                value={passwordConfirmation}
                                onFocus={() => setIsFocused('password_confirmation')}
                                onBlur={() => setIsFocused(null)}
                                onChange={(e) => setPasswordConfirmation(e.target.value)}
                            />
                        </div>
                    </div>

                    <motion.button
                        type="submit"
                        className="btn-auth-submit"
                        disabled={loading}
                        whileHover={{ scale: 1.01 }}
                        whileTap={{ scale: 0.99 }}
                    >
                        <AnimatePresence mode="wait">
                            {loading ? (
                                <motion.div
                                    key="loading"
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    exit={{ opacity: 0 }}
                                    className="btn-content"
                                >
                                    <Loader2 className="spinner" size={20} />
                                    <span>Creating account...</span>
                                </motion.div>
                            ) : (
                                <motion.div
                                    key="idle"
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    exit={{ opacity: 0 }}
                                    className="btn-content"
                                >
                                    <span>Sign up</span>
                                    <UserPlus size={18} />
                                </motion.div>
                            )}
                        </AnimatePresence>
                    </motion.button>
                </form>

                <div className="auth-footer">
                    <p>Already have an account? <a href={loginPath} className="accent-link">Sign in</a></p>
                </div>
            </motion.div>

            <style dangerouslySetInnerHTML={{
                __html: `
        .auth-container {
          min-height: 85vh;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 24px;
          background: radial-gradient(circle at top left, rgba(35, 134, 54, 0.1), transparent 400px),
                      radial-gradient(circle at bottom right, rgba(47, 129, 247, 0.05), transparent 400px);
        }

        .auth-card {
          background: rgba(13, 17, 23, 0.7);
          backdrop-filter: blur(16px) saturate(180%);
          -webkit-backdrop-filter: blur(16px) saturate(180%);
          border: 1px solid rgba(255, 255, 255, 0.1);
          border-radius: 28px;
          padding: 48px;
          width: 100%;
          max-width: 440px;
          box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        .auth-header {
          text-align: center;
          margin-bottom: 40px;
        }

        .brand-icon {
          width: 64px;
          height: 64px;
          background: linear-gradient(135deg, var(--success-color), #3fb950);
          border-radius: 16px;
          display: flex;
          align-items: center;
          justify-content: center;
          margin: 0 auto 24px;
          color: white;
          box-shadow: 0 8px 16px rgba(35, 134, 54, 0.25);
        }

        .auth-header h1 {
          font-family: var(--font-display);
          font-size: 2rem;
          font-weight: 800;
          margin: 0 0 8px;
          color: var(--text-primary);
          letter-spacing: -0.02em;
        }

        .auth-header p {
          color: var(--text-secondary);
          font-size: 1rem;
        }

        .auth-form {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        .form-group {
          display: flex;
          flex-direction: column;
          gap: 8px;
          transition: transform 0.2s ease;
        }

        .form-group.focused {
          transform: translateY(-2px);
        }

        .form-group label {
          font-size: 0.9rem;
          font-weight: 600;
          color: var(--text-primary);
          margin-left: 4px;
        }

        .input-wrapper {
          position: relative;
          display: flex;
          align-items: center;
        }

        .form-input {
          width: 100%;
          background: rgba(255, 255, 255, 0.03);
          border: 1px solid rgba(255, 255, 255, 0.1);
          border-radius: 14px;
          padding: 14px 16px 14px 48px;
          color: var(--text-primary);
          font-size: 1rem;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .form-input::placeholder {
          color: rgba(255, 255, 255, 0.2);
        }

        .form-input:focus {
          outline: none;
          background: rgba(255, 255, 255, 0.05);
          border-color: var(--success-color);
          box-shadow: 0 0 0 4px rgba(35, 134, 54, 0.15);
        }

        .input-icon {
          position: absolute;
          left: 16px;
          color: var(--text-secondary);
          transition: color 0.3s ease;
        }

        .input-icon.success {
          color: var(--success-color);
        }

        .form-group.focused .input-icon {
          color: var(--success-color);
        }

        .password-toggle {
          position: absolute;
          right: 8px;
          background: transparent;
          border: none;
          color: var(--text-secondary);
          padding: 8px;
          cursor: pointer;
          border-radius: 10px;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: all 0.2s ease;
        }

        .password-toggle:hover {
          background: rgba(255, 255, 255, 0.05);
          color: var(--text-primary);
        }

        .btn-auth-submit {
          background: var(--success-color);
          color: white;
          border: none;
          border-radius: 14px;
          padding: 16px;
          font-size: 1rem;
          font-weight: 700;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          box-shadow: 0 10px 20px -5px rgba(35, 134, 54, 0.4);
          transition: box-shadow 0.2s ease;
          margin-top: 12px;
        }

        .btn-content {
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .spinner {
          animation: spin 1s linear infinite;
        }

        @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }

        .auth-footer {
          text-align: center;
          margin-top: 32px;
          padding-top: 24px;
          border-top: 1px solid rgba(255, 255, 255, 0.05);
        }

        .auth-footer p {
          color: var(--text-secondary);
          font-size: 0.95rem;
        }

        .accent-link {
          color: var(--accent-color);
          text-decoration: none;
          font-weight: 700;
        }

        .accent-link:hover {
          text-decoration: underline;
        }
      ` }} />
        </div>
    )
}

export default SignupForm
