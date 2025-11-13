// Login page with role-based authentication (NGO, Volunteer)

import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Mail, Lock, AlertCircle, Heart } from 'lucide-react';
import { useAuthStore } from '../store/authStore';
import Input from '../components/Input';
import Button from '../components/Button';

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required')
});

type LoginFormData = z.infer<typeof loginSchema>;
type UserRole = 'ngo' | 'volunteer';

export const Login: React.FC = () => {
  const [activeRole, setActiveRole] = useState<UserRole>('ngo');
  const [error, setError] = useState<string>('');
  const { login, isLoading } = useAuthStore();
  const navigate = useNavigate();

  const {
    register,
    handleSubmit,
    formState: { errors }
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema)
  });

  const onSubmit = async (data: LoginFormData) => {
    try {
      setError('');
      await login(data.email, data.password, activeRole);

      if (activeRole === 'ngo') {
        navigate('/ngo/dashboard');
      } else {
        navigate('/volunteer/dashboard');
      }
    } catch (err) {
      setError('Invalid email or password. Please try again.');
    }
  };

  return (
    <div className="min-h-screen bg-neutral-50 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <Link to="/" className="inline-flex items-center gap-2 mb-4">
            <Heart className="w-8 h-8 text-primary-600" />
            <span className="font-display font-bold text-2xl text-neutral-900">CommunityConnect</span>
          </Link>
          <h1 className="text-3xl font-bold font-display text-neutral-900 mb-2">Welcome Back</h1>
          <p className="text-neutral-600">Sign in to continue making a difference</p>
        </div>

        <div className="bg-white rounded-2xl shadow-lg p-8">
          <div className="flex gap-2 mb-6">
            {(['ngo', 'volunteer'] as UserRole[]).map((role) => (
              <button
                key={role}
                onClick={() => setActiveRole(role)}
                className={`flex-1 py-2.5 px-4 rounded-lg font-semibold text-sm capitalize transition-all ${
                  activeRole === role
                    ? 'bg-primary-600 text-white shadow-md'
                    : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                }`}
              >
                {role}
              </button>
            ))}
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6 flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-red-600 shrink-0 mt-0.5" />
              <p className="text-sm text-red-800">{error}</p>
            </div>
          )}

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div>
              <Input
                {...register('email')}
                type="email"
                placeholder="Email address"
                icon={Mail}
                error={errors.email?.message}
              />
            </div>

            <div>
              <Input
                {...register('password')}
                type="password"
                placeholder="Password"
                icon={Lock}
                error={errors.password?.message}
              />
            </div>

            <Button type="submit" variant="primary" className="w-full" disabled={isLoading}>
              {isLoading ? 'Signing in...' : 'Sign In'}
            </Button>
          </form>

          {activeRole === 'ngo' && (
            <p className="mt-6 text-center text-sm text-neutral-600">
              New NGO?{' '}
              <Link to="/register-ngo" className="text-primary-600 font-semibold hover:text-primary-700">
                Register here
              </Link>
            </p>
          )}

          {activeRole === 'volunteer' && (
            <p className="mt-6 text-center text-sm text-neutral-600">
              Don't have an account?{' '}
              <Link to="/register-volunteer" className="text-primary-600 font-semibold hover:text-primary-700">
                Sign up
              </Link>
            </p>
          )}
        </div>

        <div className="text-center mt-6">
          <Link to="/" className="text-sm text-neutral-600 hover:text-primary-600 font-medium">
            ← Back to Home
          </Link>
        </div>
      </div>
    </div>
  );
};
